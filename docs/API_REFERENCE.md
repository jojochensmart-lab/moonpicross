# MoonPicross core API

Import jojochensmart-lab/moonpicross/core. Existing v0.1.0 entry points and public records remain available. See [model and error contracts](API.md).

- Puzzle::from_json parses and validates JSON v1. Puzzle::from_grid derives clues from a complete typed grid. Puzzle::solve validates the model and returns a result or a PuzzleError.
- solve accepts raw row and column clues, Limits and optional trace count. solve_bounded adds max_depth, where 0 allows propagation at the root and no branching. The internal maximum remains 256. Negative limits are invalid.
- SolveResult.first may contain the first solution even if status is Budget. Multiple proves at least two. Unique requires a completed search.
- Metrics.patterns counts enumerated masks, largest is the largest line domain, rounds counts propagation passes, nodes counts entered search states, backtracks counts completed branches with no new solution and scans counts candidate masks examined. Cache hits use no scan budget. Work counts and the first witness can change between solver versions. Measure wall time outside core.
- GenerationConfig::run and generate use a UInt32 seed, size, density, attempt budget and optional difficulty band. A result certifies uniqueness. Difficulty is a solver-effort band, so a different solver version can assign a different label.
- The existing generated snapshots describe v0.1.0. Use this reference and the source for the additive depth API.

Run examples/solve, examples/unique and examples/generate with moon run and the wasm-gc target.
