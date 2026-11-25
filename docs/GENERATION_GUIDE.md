# Generating puzzles

Keep the engine version, size, seed, density, attempt limit, solver budgets and difficulty filter together when recording a generation request. Export JSON v1 clues for interchange across versions. Seed 0 maps to 1.

Candidate boards initially sample cells independently with the deterministic xorshift stream. Starting with attempt 9 on boards at least 15×15, alternating retries encourage runs along rows or columns. The density parameter is a target probability. The number of attempts and solver budgets are unchanged. Only a completed uniqueness proof accepts a board. An attempt exhausted error means no candidate met the constraints within that request.

Run moon run examples/generate --target wasm-gc for an executable example. The 700-seed survey measures 200 seeds at 5×5, 10×10 and 15×15 and 100 at 20×20. It replays every successful seed, reconstructs clues from the witness and checks that the independent solve call returns that witness as the sole solution. See [measured outcomes](V020_BENCHMARK_REPORT.md). Larger boards and requested difficulty filters may substantially lower success.
