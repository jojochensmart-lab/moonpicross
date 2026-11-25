import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import { mkdir, mkdtemp, readFile, writeFile } from "node:fs/promises";
import { join, resolve } from "node:path";
import { pathToFileURL } from "node:url";
import { setTimeout as delay } from "node:timers/promises";

async function waitFor(check) {
  const deadline = Date.now() + 15000;
  do {
    try {
      const result = await check();
      if (result) return result;
    } catch (error) {
      if (error.code !== "ENOENT" && !(error instanceof TypeError)) throw error;
    }
    await delay(100);
  } while (Date.now() < deadline);
  throw new Error("Timed out waiting for Edge");
}

const edge = process.env.MOONPICROSS_EDGE ?? join(process.env["ProgramFiles(x86)"],
  "Microsoft", "Edge", "Application", "msedge.exe");
await mkdir("_build", { recursive: true });
const folder = await mkdtemp(resolve("_build/edge-files-"));
const downloads = join(folder, "downloads");
await mkdir(downloads);
const source = join(folder, "source.json");
const puzzle = { version: 1, rows: [[2]], cols: [[1], [1]] };
await writeFile(source, JSON.stringify(puzzle));
const profile = join(folder, "profile");
const browser = spawn(edge, [
  "--headless=new", "--no-first-run", "--disable-background-networking",
  "--remote-debugging-port=0", "--user-data-dir=" + profile,
  pathToFileURL(resolve("studio/index.html")).href
], { windowsHide: true, stdio: "ignore" });
let socket;
let launchError;
browser.on("error", error => { launchError = error; });
try {
  const port = await waitFor(async () => {
    if (launchError) throw launchError;
    return (await readFile(join(profile, "DevToolsActivePort"), "utf8")).split("\n")[0];
  });
  const page = await waitFor(async () => (await (await fetch("http://127.0.0.1:" + port + "/json/list"))
    .json()).find(target => target.url.endsWith("/studio/index.html")));
  socket = new WebSocket(page.webSocketDebuggerUrl);
  await new Promise((done, fail) => {
    socket.addEventListener("open", done, { once: true });
    socket.addEventListener("error", fail, { once: true });
  });
  let id = 0;
  const pending = new Map();
  const events = new Map();
  socket.addEventListener("message", event => {
    const msg = JSON.parse(event.data);
    if (msg.id) {
      pending.get(msg.id)?.(msg);
      pending.delete(msg.id);
    } else {
      events.get(msg.method)?.(msg.params);
      events.delete(msg.method);
    }
  });
  function send(method, params = {}) {
    const request = ++id;
    return new Promise((done, fail) => {
      const timeout = setTimeout(() => {
        pending.delete(request);
        fail(new Error("Edge command timed out: " + method));
      }, 10000);
      pending.set(request, msg => {
        clearTimeout(timeout);
        if (msg.error) fail(new Error(msg.error.message));
        else done(msg.result);
      });
      socket.send(JSON.stringify({ id: request, method, params }));
    });
  }
  async function evaluate(expression) {
    const answer = await send("Runtime.evaluate", { expression, returnByValue: true });
    if (answer.exceptionDetails) throw new Error(answer.exceptionDetails.text);
    return answer.result.value;
  }
  await send("Page.enable");
  await send("Page.setInterceptFileChooserDialog", { enabled: true });
  await send("Browser.setDownloadBehavior", { behavior: "allow", downloadPath: downloads });
  async function chooseFile(path) {
    const chosen = new Promise(resolveEvent => events.set("Page.fileChooserOpened", resolveEvent));
    const { x, y } = await evaluate("(() => {const r = document.querySelector('#load').getBoundingClientRect(); return {x:r.left+10,y:r.top+r.height/2};})()");
    await send("Input.dispatchMouseEvent", { type: "mousePressed", button: "left", clickCount: 1, x, y });
    await send("Input.dispatchMouseEvent", { type: "mouseReleased", button: "left", clickCount: 1, x, y });
    const { backendNodeId } = await Promise.race([chosen, delay(5000, null, {ref:false})]) ?? {};
    assert.ok(backendNodeId, "Edge must open the real file input");
    await send("DOM.setFileInputFiles", { files: [path], backendNodeId });
  }
  const cellCount = count => waitFor(() => evaluate("document.querySelectorAll('#board .cell').length === " + count));
  const status = fragment => waitFor(() => evaluate("document.querySelector('#status').textContent.includes(" +
    JSON.stringify(fragment) + ")"));
  await chooseFile(source);
  await cellCount(2);
  await evaluate("document.querySelector('#save').click()");
  const exported = join(downloads, "moonpicross.json");
  const content = await waitFor(() => readFile(exported, "utf8"));
  assert.deepEqual(JSON.parse(content), puzzle);
  await evaluate("document.querySelector('#sample').click()");
  await cellCount(25);
  await chooseFile(exported);
  await cellCount(2);
  const bad = join(folder, "bad.json");
  await writeFile(bad, "{ broken");
  await chooseFile(bad);
  await status("InvalidFormat");
  await writeFile(bad, Buffer.from([0xc3, 0x28]));
  await chooseFile(bad);
  await status("UTF-8");
  await cellCount(2);

  const large = join(folder, "20x20.json");
  await writeFile(large, JSON.stringify({
    version: 1, rows: Array.from({length:20}, () => [1]), cols: Array.from({length:20}, () => [1])
  }));
  await send("Emulation.setDeviceMetricsOverride", {width:420, height:850, deviceScaleFactor:1, mobile:false});
  await chooseFile(large);
  await cellCount(400);
  await evaluate("document.querySelector('.cell').focus()");
  await send("Input.dispatchKeyEvent", {type:"rawKeyDown", key:"ArrowLeft", code:"ArrowLeft", windowsVirtualKeyCode:37});
  assert.equal(await evaluate("document.activeElement.getAttribute('aria-label')"), "Row 1, column 1, unknown");
  await send("Input.dispatchKeyEvent", {type:"rawKeyDown", key:"ArrowRight", code:"ArrowRight", windowsVirtualKeyCode:39});
  assert.equal(await evaluate("document.activeElement.getAttribute('aria-label')"), "Row 1, column 2, unknown");
  await evaluate("document.activeElement.click()");
  assert.equal(await evaluate("document.querySelectorAll('.clue.satisfied').length"), 2);
  assert.equal(await evaluate("document.querySelectorAll('.clue.active-line').length"), 2);
  assert.equal(await evaluate("document.querySelector('#board-shell').scrollWidth > document.querySelector('#board-shell').clientWidth"), true);
  const screenshot = await send("Page.captureScreenshot");
  await writeFile(join(folder, "20x20.png"), Buffer.from(screenshot.data, "base64"));
  await send("Page.reload");
  await cellCount(25);
  assert.equal(await evaluate("document.querySelector('#undo').disabled && document.querySelectorAll('.black,.white').length === 0"), true);
  console.log("Edge verified disk import, disk export/re-import, malformed files, 20x20 controls and refresh: " + folder);
} finally {
  socket?.close();
  browser.kill();
}
