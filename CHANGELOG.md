# Changelog

## 0.2.0 — Release candidate

- **Solver.** Cache line analysis by the full black and white masks. Branch on cells incident to smaller surviving line domains. With the cache held constant, mean search nodes on 60 fixed 15×15 cases fell from 113.30 to 49.17 compared with first-unknown branching. The isolated 20×20 timing was roughly flat.
- **Limits and errors.** Add solve_bounded with a configurable depth ceiling. Existing APIs and JSON v1 remain compatible. Budget still marks an unfinished search even when a first witness exists. Validate clues before spending candidate budget and reject negative generation budgets as InvalidOptions.
- **Generation.** For boards at least 15×15, alternate structured retries with the original sampling from attempt nine. Keep the 24-attempt survey cap. On original seeds, 15×15 improved from 189/200 to 200/200 and 20×20 from 41/100 to 84/100. The Wasm GC release benchmark measured mean generation times per seed of 33.64 → 6.88 ms for 15×15 and 333.06 → 104.50 ms for 20×20.
- **Studio.** Add undo, redo, keyboard navigation, clue feedback and clearing marks. Import strictly decoded UTF-8 JSON without triggering solving. Export JSON v1 with disk download and re-import verified in Edge.

| Board | Original seed cohort | Independent new cohort |
|---|---:|---:|
| 5×5 | 200/200 | 200/200 |
| 10×10 | 200/200 | 200/200 |
| 15×15 | 200/200 | 197/200 |
| 20×20 | 84/100 | 168/200 |

All 1,449 successful witnesses per backend were replayed and checked by a separate Python solver. The Python Oracle agreed on 15,745 cases. Windows passed 18/18 each on Native, Wasm GC and JS, and Linux passed 18/18 each on Wasm GC and JS. Edge and extracted-package smoke tests passed. [Candidate CI](https://github.com/jojochensmart-lab/moonpicross/actions/runs/45604621651)

Studio creates boards from 5×5 to 15×15. Import supports larger boards, and 20×20 generation remains exploratory. Seeds reproduce within the same engine version and configuration. Search order, witnesses and solver-effort difficulty can change across versions. Difficulty has no human calibration. Edge file selection used DevTools. Manual use of the Windows system dialog remains unverified. Registry installation of 0.2.0 is a post-publication check.

## 0.1.0 — 2026-11-25

- Added a validated typed puzzle model and version 1 JSON import.
- Exposed bounded uniqueness checking, search metrics and optional step traces.
- Added deterministic generation with configurable limits and difficulty filtering.
- Built an offline browser studio for play, editing, analysis and puzzle exchange.
- Added independent exhaustive checks, runnable examples, local archive verification and a GitHub Actions workflow.

- Published the core on Mooncakes and verified Windows Native CI, GitHub Pages and the offline release ZIP.
