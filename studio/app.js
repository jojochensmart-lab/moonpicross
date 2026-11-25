"use strict";
const sample = {version:1, rows:[[1],[3],[5],[3],[1]], cols:[[1],[3],[5],[3],[1]]};
const $ = id => document.getElementById(id);
const parse = JSON.parse;
let puzzle = sample, marks = [], cells = [], editing = false;
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
  const complete = puzzle.rows.every((row,y) => sameClues(Array.from({length:w},(_,x) => bit(y,x)),row)) &&
    puzzle.cols.every((col,x) => sameClues(Array.from({length:h},(_,y) => bit(y,x)),col));
  message(complete ? "Puzzle completed." : "");
}
function showPuzzle(next, edit = false) {
  puzzle = next;
  editing = edit;
  $("derive").disabled = !edit;
  $("solve").disabled = edit;
  $("save").disabled = edit;
  $("board").replaceChildren();
  $("steps").replaceChildren();
  showAnalysis(null, 0);
  const w = next.cols.length, h = next.rows.length;
  marks = Array(w*h).fill(-1); cells = [];
  $("board").style.gridTemplateColumns = "minmax(3rem,max-content) repeat(" + w + ",auto)";
  label("");
  next.cols.forEach(col => label(edit ? "" : clues(col).replaceAll(" ","\n")));
  for (let y=0; y<h; y++) {
    label(edit ? "" : clues(next.rows[y]));
    for (let x=0; x<w; x++) {
      const i = y*w+x, cell = document.createElement("button");
      cell.type = "button";
      const mark = state => { marks[i]=state; paint(i); checkComplete(); };
      cell.onclick = () => mark(marks[i] === -1 ? 1 : marks[i] === 1 ? 0 : -1);
      cell.oncontextmenu = e => { e.preventDefault(); mark(marks[i] === 0 ? -1 : 0); };
      cells.push(cell); $("board").append(cell); paint(i);
    }
  }
  message(edit ? "Draw the black cells, then apply clues. Unmarked cells become white." : "Ready.");
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
    marks = result.first; cells.forEach((_,i) => paint(i));
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
  const {result} = analyze(source);
  if (result.error) { message(result.error); return false; }
  showPuzzle(result.puzzle);
  return true;
}
function sizeValue() {
  const n = Number($("size").value);
  return Number.isInteger(n) && n>=5 && n<=15 ? n : 0;
}
$("sample").onclick = () => showPuzzle(sample);
$("reset").onclick = () => showPuzzle(puzzle,editing);
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
    try { if(file.size>32768) message("Puzzle file exceeds 32 KiB."); else importPuzzle(await file.text()); }
    catch { message("Unable to read the puzzle file."); }
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
if(location.search==="?probe") {
  const assert = (cond,why) => { if(!cond) throw Error(why); };
  cells[0].click(); assert(marks[0]===1,"black"); cells[0].click(); assert(marks[0]===0,"white");
  cells[0].click(); assert(marks[0]===-1,"unknown");
  $("solve").click(); assert(marks.filter(v=>v===1).length===13 && $("steps").children.length>0,"solve and trace");
  assert(importPuzzle(exportText()),"file codec");
  assert(!importPuzzle('{"version":2}'),"invalid file");
  $("edit").click(); cells[0].click(); $("derive").click(); assert(puzzle.rows[0][0]===1,"derive");
  $("seed").value="7"; $("generate").click(); assert($("status").textContent.includes("Unique puzzle generated"),"generate");
  $("size").value=15; $("edit").click(); assert(cells.length===225,"large grid");
  $("sample").click(); $("reset").click(); assert(marks.every(v=>v===-1),"reset");
  document.body.dataset.probe="passed";
}
