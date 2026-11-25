# v0.2.0 development plan

Baseline main 253a51b is two documentation commits ahead of v0.1.0 (2dc7550). The application form exists separately and contains all eight sections. Preserve it, including the existing personal fields. Release tags and package versions already published are outside this local development run.

Core validates clues and enumerates immutable bit-mask domains. Search re-scans every domain each pass, even when its assignments have not changed. First-unknown branching ignores surviving candidate counts. The generator uses a fixed xorshift stream with independent per-cell density and accepts only proven unique results. Existing coverage includes an exhaustive Python oracle and a 300-seed survey. The browser statically loads a JS bridge, reruns full solving on import, and verifies a simulated file exchange without proving download to disk.

| Work | Acceptance |
|---|---|
| Search | Compare identical clues, budgets and targets. Skip repeat domain scans, evaluate a domain-based branching heuristic, preserve proof semantics. |
| Generation | Run 200 seeds at 5, 10 and 15, and 100 at 20. Verify witnesses, repeatability and uniqueness at unchanged effort limits. |
| Studio | Add keyboard and editing controls. Verify a real Edge file input and disk download in an isolated profile. |
| API and quality | Preserve existing public records. Add a bounded API and a uniqueness example. Exercise malformed inputs and depth limits. |
| Benchmarks | Record separate JS and Wasm GC timings, P95, work counters and budget rates. Keep raw logs under the build directory. |
| CI and release candidate | Run local format/check/build/test, examples, browser probe and archive smoke. Keep hosted CI, native environment and publication claims tied to actual evidence. |

Search order and runtime effort can change the first witness, difficulty band and selected puzzle. Seeds are reproducible within a fixed engine version and configuration. Preserve JSON v1 and existing APIs. No new runtime dependencies, telemetry or remote writes.
