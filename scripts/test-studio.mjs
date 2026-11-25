import assert from "node:assert/strict";
await import("../studio/engine.js");
const example = { version: 1, rows: [[1],[3],[5],[3],[1]], cols: [[1],[3],[5],[3],[1]] };
const response = JSON.parse(globalThis.solve_puzzle(JSON.stringify(example)));
assert.equal(response.status,"Unique");
assert.equal(response.first.length,25);
assert.equal(response.first.filter(x=>x===1).length,13);
assert.ok(response.steps.length>0);
assert.deepEqual(JSON.parse(globalThis.derive_puzzle(5, response.first.join(""))),example);
const generated = JSON.parse(globalThis.generate_puzzle(5,7,"Easy"));
assert.equal(generated.difficulty.level,"Easy");
assert.equal(JSON.parse(globalThis.solve_puzzle(JSON.stringify(generated.puzzle))).status,"Unique");
for (const source of ["{}", "{", JSON.stringify({...example,version:2})]) {
  assert.ok(JSON.parse(globalThis.solve_puzzle(source)).error);
}
console.log("Studio bridge: solve, trace, clue derivation, seeded generation, invalid JSON passed");
