"use strict";
const sample = {version:1, rows:[[1],[3],[5],[3],[1]], cols:[[1],[3],[5],[3],[1]]};
const $ = id => document.getElementById(id);
const parse = JSON.parse;
let puzzle = sample, marks = [], cells = [], editing = false;
let undo = [], redo = [], rowLabels = [], colLabels = [];
const historyLimit = 100;

function historyButtons() {
  $("undo").disabled = undo.length === 0;
  $("redo").disabled = redo.length === 0;
}
function updateMarks(next) {
  if (next.every((value, index) => value === marks[index])) return;
  remember(undo);
  redo = [];
  marks = next;
  refresh();
}
function remember(stack) {
  if (stack.length >= historyLimit) stack.shift();
  stack.push(marks);
}
function restore(from, into) {
  if (!from.length) return;
  remember(into);
  marks = from.pop();
  refresh();
}
function refresh() {
  cells.forEach((_, index) => paint(index));
  historyButtons();
  checkComplete();
}
function moveFocus(event, index) {
  const width = puzzle.cols.length;
  const col = index % width;
  const movement = {
    ArrowLeft: col > 0 ? -1 : 0,
    ArrowRight: col + 1 < width ? 1 : 0,
    ArrowUp: -width,
    ArrowDown: width
  };
  if (event.key.toLowerCase() === "x") {
    event.preventDefault();
    cells[index].dispatchEvent(new MouseEvent("contextmenu", {cancelable:true}));
  } else if (Object.hasOwn(movement, event.key)) {
    event.preventDefault();
    cells[index + movement[event.key]]?.focus();
  }
}
function highlight(index) {
  const width = puzzle.cols.length;
  rowLabels.forEach((label, i) => label.classList.toggle("active-line", i === Math.floor(index / width)));
  colLabels.forEach((label, i) => label.classList.toggle("active-line", i === index % width && index >= 0));
}
const run = (fn, ...args) => parse(globalThis[fn](...args));
function message(text) { $("status").textContent = text; }
function showAnalysis(report, ms) {
  $("metrics").textContent = report ? [
    report.level, report.nodes + " nodes", report.rounds + " rounds",
    report.candidates + " candidates", ms.toFixed(1) + " ms"
  ].join(" · ") : "";
}
function label(content) {
  const span = document.createElement("span");
  span.className = "clue";
  span.textContent = content;
  $("board").append(span);
  return span;
}
function paint(i) {
  const state = marks[i], cell = cells[i];
  cell.className = "cell " + ({1:"black",0:"white"}[state] ?? "");
  cell.textContent = state === 0 ? "×" : "";
  cell.setAttribute("aria-label", "Row " + (Math.floor(i / puzzle.cols.length) + 1) +
    ", column " + (i % puzzle.cols.length + 1) + ", " +
    ({1:"black",0:"white"}[state] ?? "unknown"));
}
function clues(line) {
  return line.length ? line.join(" ") : "0";
}
function sameClues(bits, expected) {
  const runs = Array.from(bits.join("").matchAll(/1+/g), match => match[0].length);
  return runs.length === expected.length && runs.every((v,i) => v === expected[i]);
}
function checkComplete() {
  if (editing) return;
  const w = puzzle.cols.length, h = puzzle.rows.length;
  const bit = (row,col) => Number(marks[row*w+col] === 1);
  function matched(labels, hints, line) {
    let count = 0;
    hints.forEach((clue, i) => {
      const ok = sameClues(line(i), clue);
      labels[i].classList.toggle("satisfied", ok);
      if (ok) count++;
    });
    return count;
  }
  const rows = matched(rowLabels, puzzle.rows, y => Array.from({length:w}, (_,x) => bit(y,x)));
  const cols = matched(colLabels, puzzle.cols, x => Array.from({length:h}, (_,y) => bit(y,x)));
  message(rows === h && cols === w ? "Puzzle completed." :
    rows + "/" + h + " rows and " + cols + "/" + w + " columns match.");
}
function showPuzzle(next, edit = false) {
  puzzle = next;
  editing = edit;
  $("derive").disabled = !edit;
  $("check").disabled = edit;
  $("solve").disabled = edit;
  $("save").disabled = edit;
  $("board").replaceChildren();
  $("steps").replaceChildren();
  showAnalysis(null, 0);
  const w = next.cols.length, h = next.rows.length;
  marks = Array(w*h).fill(-1); cells = [];
  undo = []; redo = []; rowLabels = []; colLabels = [];
  historyButtons();
  $("board").style.gridTemplateColumns = "minmax(3rem,max-content) repeat(" + w + ",auto)";
  label("");
  colLabels = next.cols.map(col => label(edit ? "" : clues(col).replaceAll(" ","\n")));
  for (let y=0; y<h; y++) {
    rowLabels.push(label(edit ? "" : clues(next.rows[y])));
    for (let x=0; x<w; x++) {
      const i = y*w+x, cell = document.createElement("button");
      cell.type = "button";
      const mark = state => {
        const next = marks.slice();
        next[i] = state;
        updateMarks(next);
      };
      cell.onkeydown = event => moveFocus(event, i);
      cell.onfocus = () => highlight(i);
      cell.onmouseenter = () => highlight(i);
      cell.onclick = () => mark(marks[i] === -1 ? 1 : marks[i] === 1 ? 0 : -1);
      cell.oncontextmenu = e => { e.preventDefault(); mark(marks[i] === 0 ? -1 : 0); };
      cells.push(cell); $("board").append(cell); paint(i);
    }
  }
  if (edit) message("Draw the black cells, then apply clues. Unmarked cells become white.");
  else checkComplete();
}
function analyze(source) {
  const t = performance.now();
  const result = run("solve_puzzle",source);
  return {result, ms: performance.now() - t};
}
function solve() {
  const {result,ms} = analyze(JSON.stringify(puzzle));
  if (result.error) { message(result.error); return; }
  showAnalysis(result.difficulty,ms);
  message(({Unique:"Unique solution",Multiple:"Multiple solutions; showing the first",
    NoSolution:"No solution",Budget:"Budget reached; uniqueness unknown"})[result.status] ?? result.status);
  if (result.first.length && result.status !== "Budget") {
    updateMarks(result.first);
    message(result.status === "Unique" ? "Unique solution shown." : "Multiple solutions; showing the first.");
  }
  const list = $("steps");
  list.replaceChildren();
  for (const step of result.steps) {
    const item = document.createElement("li");
    const line = step.kind === "column" ? step.line - puzzle.rows.length + 1 : step.line + 1;
    item.textContent = [
      "Depth " + step.depth, step.kind + (step.line >= 0 ? " " + line : ""),
      step.candidates + " candidates", step.indices.map((n,i) =>
        "(" + (Math.floor(n/puzzle.cols.length)+1) + "," + (n%puzzle.cols.length+1) + ")=" + step.values[i]
      ).join(" ")
    ].filter(Boolean).join(" · ");
    list.append(item);
  }
  if (result.trace_truncated) {
    const item = document.createElement("li"); item.textContent = "Trace reached its display cap."; list.append(item);
  }
}
function importPuzzle(source) {
  if (source.length > 32768) { message("Puzzle file exceeds 32 KiB."); return false; }
  const result = run("validate_puzzle", source);
  if (result.error) { message(result.error); return false; }
  showPuzzle(result.puzzle);
  return true;
}
function sizeValue() {
  const n = Number($("size").value);
  return Number.isInteger(n) && n>=5 && n<=15 ? n : 0;
}
$("sample").onclick = () => showPuzzle(sample);
$("reset").onclick = () => updateMarks(marks.map(() => -1));
$("undo").onclick = () => restore(undo, redo);
$("redo").onclick = () => restore(redo, undo);
$("check").onclick = checkComplete;
document.addEventListener("keydown", event => {
  if (!(event.ctrlKey || event.metaKey) || event.target.matches("input, select, textarea")) return;
  if (event.key.toLowerCase() === "z") {
    event.preventDefault();
    if (event.shiftKey) restore(redo, undo);
    else restore(undo, redo);
  }
});
$("solve").onclick = solve;
$("edit").onclick = () => {
  const n=sizeValue();
  if (!n) {message("Select an integer size from 5 to 15.");return;}
  showPuzzle({version:1,rows:Array.from({length:n},()=>[]),cols:Array.from({length:n},()=>[])},true);
};
$("derive").onclick = () => {
  const result = run("derive_puzzle",puzzle.rows.length,marks.map(v=>v===1?"1":"0").join(""));
  if(result.error){message(result.error);return;} showPuzzle(result);
};
$("generate").onclick = () => {
  const n=sizeValue(), seed=Number($("seed").value);
  if(!n || !Number.isInteger(seed) || seed<0 || seed>4294967295){message("Check size and UInt32 seed.");return;}
  const t=performance.now(), result=run("generate_puzzle",n,seed,$("level").value);
  if(result.error){message("Generation ended: "+result.error);return;}
  showPuzzle(result.puzzle); showAnalysis(result.difficulty,performance.now()-t);
  message("Unique puzzle generated in "+result.attempts+" attempts.");
};
$("load").onchange = async event => {
  const file=event.target.files[0];
  if(file) {
    try {
      if (file.size > 32768) {
        message("Puzzle file exceeds 32 KiB.");
      } else {
        const source = new TextDecoder("utf-8", { fatal: true }).decode(await file.arrayBuffer());
        importPuzzle(source);
      }
    } catch {
      message("Unable to read the puzzle file as UTF-8.");
    }
  }
  event.target.value="";
};
function exportText() { return JSON.stringify(puzzle,null,2); }
$("save").onclick = () => {
  const url=URL.createObjectURL(new Blob([exportText()],{type:"application/json"}));
  const anchor=document.createElement("a"); anchor.href=url; anchor.download="moonpicross.json"; anchor.click();
  setTimeout(()=>URL.revokeObjectURL(url),1000);
};
showPuzzle(sample);
if (location.search === "?probe") {
  async function probe() {
    const assert = (condition, reason) => { if (!condition) throw Error(reason); };
    cells[0].click(); assert(marks[0] === 1, "black");
    cells[0].click(); assert(marks[0] === 0, "white");
    cells[0].click(); assert(marks[0] === -1, "unknown");
    cells[0].dispatchEvent(new MouseEvent("contextmenu", {cancelable:true}));
    assert(marks[0] === 0, "context menu white");
    $("undo").click(); assert(marks[0] === -1, "undo");
    $("redo").click(); assert(marks[0] === 0, "redo");
    cells[0].focus();
    cells[0].dispatchEvent(new KeyboardEvent("keydown", {key:"ArrowRight"}));
    assert(document.activeElement === cells[1] && colLabels[1].classList.contains("active-line"), "keyboard and clue highlight");
    $("solve").click();
    assert(marks.filter(value => value === 1).length === 13 && $("steps").children.length > 0, "solve and trace");

    let download;
    const click = HTMLAnchorElement.prototype.click;
    try {
      HTMLAnchorElement.prototype.click = function() {
        download = {url:this.href, name:this.download};
      };
      $("save").click();
    } finally {
      HTMLAnchorElement.prototype.click = click;
    }
    assert(download?.name === "moonpicross.json", "export filename");
    const exported = await (await fetch(download.url)).blob();
    const input = $("load");
    const load = async (contents) => {
      const selection = new DataTransfer();
      selection.items.add(new File([contents], "puzzle.json", {type:"application/json"}));
      input.files = selection.files;
      await input.onchange({target:input});
    };
    $("edit").click();
    await load(exported);
    assert(!editing && exportText() === await exported.text(), "file round trip");
    await load(JSON.stringify({...sample, version:2}));
    assert($("status").textContent.includes("UnsupportedVersion"), "invalid file");
    await load(new Uint8Array([0xC3, 0x28]));
    assert($("status").textContent.includes("UTF-8"), "malformed UTF-8");
    assert(importPuzzle(JSON.stringify({version:1, rows:[[]], cols:[[]]})), "empty clue puzzle");
    assert(document.querySelectorAll(".clue.satisfied").length === 2, "initial clue status");
    $("edit").click(); cells[0].click(); $("derive").click();
    assert(puzzle.rows[0][0] === 1, "derive");
    $("seed").value = "7"; $("generate").click();
    assert($("status").textContent.includes("Unique puzzle generated"), "generate");
    $("size").value = 15; $("edit").click();
    const shell = $("board-shell");
    assert(cells.length === 225 && shell.scrollWidth > shell.clientWidth, "large grid scroll");
    $("sample").click(); $("reset").click();
    assert(marks.every(value => value === -1), "reset");
    document.body.dataset.probe = "passed";
  }
  probe().catch(error => {
    document.body.dataset.probe = error.message;
    console.error(error);
  });
}
