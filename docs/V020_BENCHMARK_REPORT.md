# v0.2.0 benchmark

Baseline 253a51b and the candidate used the same local MoonBit 0.1.20261028 toolchain and committed harness. Per backend the solve suite uses the same 60 clues for each size and default budgets. Timings are from one release run per version and target. P95 is the nearest-rank observation. The generator comparison uses the same seeds, density 45 and 24 attempts, and may select a different candidate after the solver or retry strategy changes. All reported successes passed replay and witness checks. Memory was not measured reliably.

At 20×20 more search states and backtracks fit within the scan ceiling. The solve mean scan count and budget exhaustion rate fell together. Timings are sensitive to warm-up and scheduling, particularly at 5×5 where the Wasm median was slightly higher. The combined search-stage changes were measured together. In a separate Wasm solver-only survey, 15×15 remained 189/200 and 20×20 reached 44/100 before adding structured retries.

## Wasm GC

| Size | Mean µs | Median µs | P95 µs | Mean nodes | Mean backtracks | Mean scans | Budget / 60 |
|---|---:|---:|---:|---:|---:|---:|---:|
| 5 | 97.39 → 39.65 | 21.15 → 23.05 | 123.30 → 63.60 | 2.00 → 1.87 | 0.05 → 0.00 | 218.35 → 96.95 | 0.00 → 0.00 |
| 10 | 153.04 → 127.88 | 114.25 → 103.55 | 383.50 → 230.50 | 5.72 → 4.98 | 1.27 → 0.98 | 8302.42 → 2572.47 | 0.00 → 0.00 |
| 15 | 4831.69 → 1346.19 | 1733.20 → 542.40 | 25559.30 → 4315.70 | 64.95 → 49.17 | 53.57 → 38.15 | 847850.77 → 192063.53 | 5.00 → 0.00 |
| 20 | 17892.97 → 8762.54 | 20500.85 → 11958.60 | 21714.20 → 15005.30 | 41.63 → 113.52 | 27.32 → 96.72 | 4232226.75 → 3190129.60 | 44.00 → 32.00 |

| Size | Certified / seeds | Mean attempts / seed | Mean nodes / attempt | Mean ms / seed | Budget attempts |
|---|---:|---:|---:|---:|---:|
| 5 | 200 → 200 / 200 | 1.57 → 1.57 | 2.12 → 2.00 | 0.03 → 0.02 | 0 → 0 |
| 10 | 200 → 200 / 200 | 2.92 → 2.92 | 6.86 → 5.48 | 0.43 → 0.20 | 0 → 0 |
| 15 | 189 → 200 / 200 | 7.86 → 6.49 | 62.16 → 50.31 | 33.64 → 6.88 | 115 → 9 |
| 20 | 41 → 84 / 100 | 18.34 → 13.84 | 41.33 → 96.71 | 333.06 → 104.50 | 1385 → 594 |

## js

| Size | Mean µs | Median µs | P95 µs | Mean nodes | Mean backtracks | Mean scans | Budget / 60 |
|---|---:|---:|---:|---:|---:|---:|---:|
| 5 | 251.67 → 98.91 | 61.15 → 48.70 | 845.40 → 305.70 | 2.00 → 1.87 | 0.05 → 0.00 | 218.35 → 96.95 | 0.00 → 0.00 |
| 10 | 317.59 → 205.11 | 203.55 → 167.95 | 1019.60 → 461.00 | 5.72 → 4.98 | 1.27 → 0.98 | 8302.42 → 2572.47 | 0.00 → 0.00 |
| 15 | 4787.07 → 1279.65 | 1715.50 → 549.70 | 25007.00 → 3296.00 | 64.95 → 49.17 | 53.57 → 38.15 | 847850.77 → 192063.53 | 5.00 → 0.00 |
| 20 | 17294.55 → 10082.81 | 19418.60 → 12325.25 | 22984.60 → 20124.40 | 41.63 → 113.52 | 27.32 → 96.72 | 4232226.75 → 3190129.60 | 44.00 → 32.00 |

| Size | Certified / seeds | Mean attempts / seed | Mean nodes / attempt | Mean ms / seed | Budget attempts |
|---|---:|---:|---:|---:|---:|
| 5 | 200 → 200 / 200 | 1.57 → 1.57 | 2.12 → 2.00 | 0.03 → 0.01 | 0 → 0 |
| 10 | 200 → 200 / 200 | 2.92 → 2.92 | 6.86 → 5.48 | 0.44 → 0.18 | 0 → 0 |
| 15 | 189 → 200 / 200 | 7.86 → 6.49 | 62.16 → 50.31 | 33.78 → 7.07 | 115 → 9 |
| 20 | 41 → 84 / 100 | 18.34 → 13.84 | 41.33 → 96.71 | 314.47 → 118.28 | 1385 → 594 |
