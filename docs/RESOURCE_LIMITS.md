# Resource limits and generation survey

| Guard | Current ceiling | Behavior |
|---|---:|---|
| Board dimensions | 30 × 30, 900 cells | Reject oversized or empty boards before enumeration |
| Candidate masks | 300,000 aggregate | Return Budget on exhaustion |
| Search nodes | 5,000 | Return Budget on exhaustion |
| Candidate scans | 5,000,000 | Return Budget on exhaustion |
| Search depth | 256 | Return Budget on exhaustion |
| Stored trace events | 2,000 | Mark trace truncated and continue search |
| Counted solutions | 2 | Stop immediately on proof of multiplicity |
| Imported JSON | 32,768 UTF-16 code units, nesting depth 8 | Reject malformed or oversized inputs |
| Generation attempts | 1,000 core, 24 in Studio | Return AttemptLimit if no accepted candidate fits the budget |

Callers can choose lower solve budgets. Limits count observable work. They are not a wall-clock deadline or a promise of browser responsiveness. A whole synchronous generation request may involve many independently bounded solves.

## Local seeded survey

Wasm GC release, seeds 1–100 per size, 45% density, at most 24 attempts, no difficulty filter. Every accepted puzzle was re-solved and its witness-derived clues matched. This second pass uses the same solver. The separate enumerating oracle covers smaller boards.

| Size | Certified / tested | Failed seeds | Budget events across attempts | Mean ms/seed | Max ms/seed | Mean nodes per candidate |
|---|---:|---:|---:|---:|---:|---:|
| 5×5 | 100 / 100 | 0 | 0 | 0.013 | 0.050 | 2.03 |
| 10×10 | 100 / 100 | 0 | 0 | 0.192 | 1.074 | 6.09 |
| 15×15 | 94 / 100 | 6 | 56 | 17.025 | 113.855 | 60.52 |

Timing includes failed seeds and depends on the host. A sampled 30×30 solve returned Budget, and the three sampled generation seeds at that size hit AttemptLimit. Those are explicit outcomes at the upper size limit. Browser generation defaults favor the smaller tested sizes.

The release run repeated the full 300-seed survey and obtained the same success counts. See [release verification](FINAL_RELEASE_ACCEPTANCE_REPORT.md).
