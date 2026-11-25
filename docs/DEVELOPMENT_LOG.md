# Development log

2026-11-25 · Stage 2

| Step | Local evidence and remaining work |
|---|---|
| A. Baseline and eligibility | Imported the independent prototype in 7588a1f and reran both five-test backends. November promotion confirmed. Exact batch dates and original charter remain pending. |
| B/C. Core and generation | dda9395 added typed input, bounded inference/search traces, deterministic filtering and metrics. ad7705d hardened JSON and budget tests. 78a292c added direct line-domain enumeration checks. Ran 300 seeded generations. |
| D. Studio | 9672821 integrated the JS bridge and offline UI. Node and actual Edge runs caught and verified a correction to the solution-grid shape. |
| E. Targets | JS and Wasm GC ran ten tests each. Local Native could not locate a suitable C compiler environment. |
| F. Examples and usage | 25181a2 added solve/generate examples. Both ran. Studio is the third runnable scenario. |
| G. CI | 25181a2 added local workflow configuration. 863d30b captured the exported API and added the packaged consumer check to CI. Hosted runs are pending. |
| H. Packaging | d74c45f exercised a downstream project from the local ZIP. Registry installation, owner and publish permissions remain pending. |
| I. Review | Recorded the source audit, open-source compliance, eligibility comparison and verifiable material for the participant. |
