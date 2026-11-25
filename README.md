# MoonPicross Studio

MoonPicross is a MoonBit library for solving, generating and verifying black-and-white Nonograms. It accepts arbitrary valid row and column clues and reports whether a puzzle has zero, one, or multiple solutions, or whether the search reached its budget. Studio uses the same solver in the browser for play, editing, trace inspection and JSON exchange.

[Online Studio](https://jojochensmart-lab.github.io/moonpicross/) · [Offline download](https://github.com/jojochensmart-lab/moonpicross/releases/tag/v0.1.0) · [GitHub](https://github.com/jojochensmart-lab/moonpicross) · [Mooncakes](https://mooncakes.io/docs/jojochensmart-lab/moonpicross)

## Install the core

In an existing MoonBit module, add the versioned dependency:

~~~sh
moon add jojochensmart-lab/moonpicross@0.1.0
~~~

Add the package to the caller's moon.pkg:

~~~moonbit
import {
  "jojochensmart-lab/moonpicross/core",
}
~~~

The core has no registry dependencies beyond the MoonBit standard library. Studio is distributed separately.

## Solve a puzzle and inspect its effort

~~~moonbit
fn main {
  let clues = [[1], [3], [5], [3], [1]]
  let puzzle : @core.Puzzle = { version: 1, rows: clues, cols: clues }
  let answer = puzzle.solve(@core.Limits::default(), trace=16).unwrap()
  guard answer.status is Unique else { abort("Expected a completed uniqueness proof") }
  println(@core.difficulty(answer).to_json().stringify())
}
~~~

Put the example in an executable package. The full [solve example](examples/solve/main.mbt) also renders the first solution. The [generation example](examples/generate/main.mbt) sets a seed and checks the returned clues again before printing the versioned puzzle. Difficulty reports solver effort and has no human-player calibration.

## Use Studio

Open the online demo, or extract the offline release ZIP and open index.html. Click a cell to cycle unknown, black and white. Right click marks it white. Draw in the editor to derive clues, or request a generated puzzle with a size and seed. Use Solve and verify to inspect the outcome and its trace. Import and export use version 1 JSON.

~~~json
{"version":1,"rows":[[1],[3],[5],[3],[1]],"cols":[[1],[3],[5],[3],[1]]}
~~~

Clue arrays list contiguous black runs in reading order. An empty clue is an empty list.

| Use case | Entry point | Result |
|---|---|---|
| Validate imported clues | [Solve example](examples/solve) | Printed grid, uniqueness status and search metrics |
| Generate a reproducible puzzle | [Generation example](examples/generate) | Seeded puzzle JSON and a second solve to confirm uniqueness |
| Edit and play | [Studio](https://jojochensmart-lab.github.io/moonpicross/) | Interactive puzzle, file exchange and step-by-step evidence |

## Build and verify from source

~~~sh
python tests/oracle.py
moon fmt --check
moon check --target wasm-gc
moon test --target wasm-gc
moon test --target js
moon run examples/solve --target wasm-gc
moon run examples/generate --target wasm-gc
node scripts/build-studio.mjs
node scripts/test-studio.mjs
~~~

For an offline source build, open studio/index.html after building. The core is in core/, the JavaScript boundary is in webapi/, and the static site is in studio/. [GitHub CI](https://github.com/jojochensmart-lab/moonpicross/actions/workflows/ci.yml) includes Windows Native as well as JS and Wasm GC.

The first release targets 5×5 through 15×15. Larger boards are exploratory. A Budget result leaves the solution count unresolved. Generation can exhaust its attempt limit, including for 15×15.

[API](docs/API.md) · [Architecture](docs/ARCHITECTURE.md) · [Tests](docs/TESTING.md) · [Resource limits](docs/RESOURCE_LIMITS.md) · [Apache-2.0](LICENSE) · [Compliance](docs/OPEN_SOURCE_COMPLIANCE.md)
