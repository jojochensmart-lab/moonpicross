# Performance

Run moon run demo --target wasm-gc --release or moon run demo --target js --release, then compare same-target CSV logs with tests/benchmark_summary.py. Each run uses 60 fixed boards per size for solve timing, then a separate generator survey. Times are wall-clock observations. Counts and budgets remain more stable than timings at small sizes. No reliable per-solve memory measurement was available.

See [the v0.2.0 comparison](V020_BENCHMARK_REPORT.md) for case counts, distributions and budget results.
