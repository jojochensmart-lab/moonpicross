# MoonPicross Studio

MoonPicross solves and generates monochrome Nonograms in MoonBit. The independent core accepts arbitrary row and column clues and distinguishes unique, multiple, impossible, invalid and budget-limited puzzles. The offline browser Studio shares that core and supports playing, editing, generating, inspecting solver steps and exchanging puzzle JSON.

## Run locally

From the project directory with MoonBit, Python 3 and Node.js available:

~~~sh
python tests/oracle.py
moon test --target wasm-gc
moon run examples/solve --target wasm-gc
moon run examples/generate --target wasm-gc
node scripts/build-studio.mjs
node scripts/test-studio.mjs
~~~

Open studio/index.html directly in a browser after the build. The page uses no network services. Use left click to cycle a cell through unknown, black and white. Right click marks a cell white. Use the editor to derive clues from a completed grid, or enter a seed and difficulty filter to generate a puzzle. Import and export use version 1 JSON.

~~~json
{"version":1,"rows":[[1],[3],[5],[3],[1]],"cols":[[1],[3],[5],[3],[1]]}
~~~

Clue arrays list contiguous black runs in reading order. An empty clue is an empty array. Rows and columns determine the grid dimensions. A budget result leaves the solution count unresolved. Difficulty is a deterministic solver-effort band.

| Scenario | Entry point | Result |
|---|---|---|
| Validate imported clues | examples/solve | Printed board, uniqueness status and search metrics |
| Generate a reproducible puzzle | examples/generate | Seeded puzzle JSON and independent second pass with the solver |
| Edit and play offline | studio/index.html | Playable puzzle, import/export and step-by-step evidence |

See [API](docs/API.md), [architecture](docs/ARCHITECTURE.md), [tests](docs/TESTING.md), [limits](docs/RESOURCE_LIMITS.md) and the [release report](docs/PROJECT_RELEASE_READINESS_REPORT.md). The local archive has been exercised in a standalone consumer. Registry publication and Windows Native validation are pending.

Licensed under [Apache-2.0](LICENSE). References and test-data provenance are in [the compliance record](docs/OPEN_SOURCE_COMPLIANCE.md).
