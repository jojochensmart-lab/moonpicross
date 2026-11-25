# Core API

Import jojochensmart-lab/moonpicross/core. The module manifest uses MoonBit's current moon.mod format. The generated interface is core/pkg.generated.mbti.

| API | Meaning |
|---|---|
| Puzzle::from_json(text) | Validates version 1, integer clues and dimensions. Returns a PuzzleError on invalid input. |
| Puzzle::from_grid(grid) | Accepts a rectangular, completely marked Grid and derives clues. |
| Puzzle::validate() | Checks dimensions and whether each clue can fit its line. |
| Puzzle::solve(limits, trace~) | Returns SolveResult or a PuzzleError. Omit trace or pass zero to disable event storage. |
| GenerationConfig::run() | Returns a certified Generated puzzle or GenerationError, with a fixed seed and optional difficulty filter. |
| difficulty(result) | Provides a solver-effort level and diagnostic counters. |

Grid holds height, width and a row-major Array[Cell]. Cell is Unknown, Black or White. RowClue and ColumnClue alias arrays of positive run lengths. SolveResult supplies status, first solution when found, steps, a truncation flag and metrics. Numeric solution grids use 1 for black and 0 for white.

A Unique result means search finished after finding exactly one solution. Multiple means two were found. NoSolution means search completed with zero. Budget means the proof is incomplete even when first contains a witness. Invalid is available through the legacy raw solve function. PuzzleError covers invalid dimensions, clues, formats, versions and incomplete grids. GenerationError distinguishes invalid options, exhausted attempts and an invariant failure.

SolveStep carries kind, line, candidate count, affected indices and values and depth. The trace is a bounded sequence of search events. It can include speculative marks followed by backtracks. The final status is available independently of trace truncation.

Prefer Puzzle::from_grid over the low-level clues(grid, height, width) helper for arbitrary input. The helper expects valid rectangular data.

The registry currently provides 0.1.0. For the 0.2.0 candidate, use the extracted archive and workspace setup in the [README](../README.md). That guide lists runnable solve, uniqueness and generation examples.
