# Architecture

Core is pure MoonBit. The browser bridge translates between structured JSON and core types, then packages JavaScript into a local script. The site has no service dependency. The examples call the same core API directly.

1. Validate dimensions, board shape and clue feasibility before constructing line domains.
2. Enumerate legal line masks, bounded by a shared candidate budget. Rows and columns use the same enumeration.
3. Filter each domain against known cells, intersect surviving possibilities and propagate forced cells until stable or contradictory. Track scans and forced cells per round.
4. Branch deterministically on the first unknown cell with a depth and node cap. Stop after the second solution. With a partial witness and exhausted resources, report Budget.
5. Generation samples from a seeded state, derives clues and accepts only a completed uniqueness proof. An optional difficulty filter also applies before acceptance.

The fixed first-unknown strategy makes search and trace reproducible. Different heuristics may help large boards. The present difficulty policy classifies unique puzzles by visited nodes: Easy at 1, Normal at 2–20, Hard at 21–100 and Expert above 100. Propagation, candidates, guesses and backtracks are reported alongside the label. The thresholds are solver-specific and require empirical calibration for human difficulty.
