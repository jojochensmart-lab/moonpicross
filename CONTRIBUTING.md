# Contributing

Use the existing MoonBit toolchain. Generate fixtures with python tests/oracle.py, then run moon fmt --check, moon check --target wasm-gc, and moon test for both wasm-gc and js. Rebuild and test the Studio JavaScript bridge for changes to its interface. See [verification commands](docs/TESTING.md).

Add an independent expected result for solver regressions where practical. Preserve the distinction between a completed uniqueness proof and a budget-limited search. Record source and license for any proposed external material. Describe the change and actual target results in the contribution. Archive consumers can follow [the release checklist](docs/RELEASE.md).
