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
try {
  const port = await waitFor(async () =>
    (await readFile(join(profile, "DevToolsActivePort"), "utf8")).split("\n")[0]);
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
      pending.set(request, msg => msg.error ? fail(new Error(msg.error.message)) : done(msg.result));
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
  const chosen = new Promise(resolveEvent => events.set("Page.fileChooserOpened", resolveEvent));
  const { x, y } = await evaluate("(() => {const r = document.querySelector('#load').getBoundingClientRect(); return {x:r.left+10,y:r.top+r.height/2};})()");
  await send("Input.dispatchMouseEvent", { type: "mousePressed", button: "left", clickCount: 1, x, y });
  await send("Input.dispatchMouseEvent", { type: "mouseReleased", button: "left", clickCount: 1, x, y });
  const { backendNodeId } = await Promise.race([chosen, delay(5000, null)] ) ?? {};
  assert.ok(backendNodeId, "Edge must open the real file input");
  await send("DOM.setFileInputFiles", { files: [source], backendNodeId });
  await waitFor(() => evaluate("document.querySelectorAll('#board .cell').length === 2"));
  await evaluate("document.querySelector('#save').click()");
  const content = await waitFor(() => readFile(join(downloads, "moonpicross.json"), "utf8"));
  assert.deepEqual(JSON.parse(content), puzzle);
  console.log("Edge chooser selected a real disk file and exported a verified file to " + downloads);
} finally {
  socket?.close();
  browser.kill();
}
