# Testing

~~~sh
python tests/oracle.py
moon fmt --check
moon check --target wasm-gc
moon build --target wasm-gc
moon test --target wasm-gc
moon test --target js
moon run examples/solve --target wasm-gc
moon run examples/generate --target wasm-gc
node scripts/build-studio.mjs
node scripts/test-studio.mjs
pwsh -NoProfile -File scripts/test-studio-edge.ps1
moon run demo --target wasm-gc --release
moon package --list
python tests/package_smoke.py
~~~

The Python oracle enumerates binary boards and groups them by their clues. The MoonBit comparison uses 15,745 assignments: all 15,625 combinations in the 3×3 clue Cartesian product and 60 cases each for 4×4 and 5×5. It also compares 141 complete line domains against 510 binary masks for lengths 1–8. Additional tests exercise contradiction, malformed clues and JSON, deterministic generation, dimensions, trace caps and candidate/search exhaustion.

The Node bridge test builds on structured sample inputs. A separate headless Edge test loads the local page at 420×850 via the probe query string. It tests marks, reset, trace, editing, the import handler with browser File objects, exported Blob content, generation and narrow-screen 15×15 scrolling. The separate node scripts/test-studio-files.mjs run uses Edge to trigger the file chooser, supplies a real disk file through DevTools, and reads the actual downloaded JSON. The Windows dialog UI is not manually exercised. Browser Wasm is outside this build path.

Native validation commands are moon build --target native and moon test --target native. The Windows runner uses the Visual Studio C++ developer environment. Results and outstanding checks are listed in [the release report](https://github.com/jojochensmart-lab/moonpicross/blob/077e40d84e68c9dac353fb80f49d90bf90680ae4/docs/PROJECT_RELEASE_READINESS_REPORT.md).

The hosted Studio uses the same probe: pwsh -NoProfile -File scripts/test-studio-edge.ps1 -Url https://jojochensmart-lab.github.io/moonpicross/. The [acceptance report](https://github.com/jojochensmart-lab/moonpicross/blob/077e40d84e68c9dac353fb80f49d90bf90680ae4/docs/FINAL_RELEASE_ACCEPTANCE_REPORT.md) records the separate fresh-project Mooncakes install and the successful Windows Native runner.
