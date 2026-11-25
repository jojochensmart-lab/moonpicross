const clues = [1,3,5,3,1];
const board = document.querySelector("#board");
const result = document.querySelector("#result");
const cells = [];
function label(value) {
  const span = document.createElement("span");
  span.textContent = value;
  board.append(span);
}
label("");
clues.forEach(label);
for (const n of clues) {
  label(n);
  for (let col = 0; col < 5; col++) {
    const cell = document.createElement("button");
    cell.className = "cell";
    cell.setAttribute("aria-label", "Cell " + (cells.length + 1));
    cell.setAttribute("aria-pressed", "false");
    cell.onclick = () => cell.setAttribute("aria-pressed", String(cell.classList.toggle("on")));
    cells.push(cell);
    board.append(cell);
  }
}
document.querySelector("#solve").onclick = () => {
  const answer = globalThis.solve_demo();
  const [status, grid] = answer.split(":");
  result.textContent = status;
  if (grid) cells.forEach((cell, i) => {
    cell.classList.toggle("on", grid[i] === "1");
    cell.setAttribute("aria-pressed", String(grid[i] === "1"));
  });
};
if (location.search === "?probe") {
  cells[0].click();
  if (!cells[0].classList.contains("on")) throw Error("click failed");
  document.querySelector("#solve").click();
  const filled = cells.filter(cell => cell.classList.contains("on")).length;
  if (result.textContent !== "Unique" || filled !== 13) throw Error("solver failed");
  result.dataset.probe = "passed";
}
