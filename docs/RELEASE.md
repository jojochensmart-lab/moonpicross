# Release checklist

1. Confirm the competition charter and the dates that apply to the intended batch.
2. Reproduce JS and Wasm GC tests. Run Native build and tests in a usable compiler environment and record the result.
3. Build and exercise the archive with moon package --list and python tests/package_smoke.py. This is a local downstream dependency using moon.work. The registry install remains a separate test.
4. Confirm module ownership and availability through the intended Mooncakes account. Add the real repository URL to the module manifest after the repository is approved and exists.
5. After separate permission to write remotely, publish the approved history to the approved repository and verify GitHub Actions on both runner platforms. Check whether the target contest requires at least ten commits visible on GitHub.
6. After explicit approval to publish, publish the reviewed module, install it from the registry in a new project, import the core and run a basic solve and example. Verify the release source and registry artifacts before announcing.

The current version is 0.1.0 and the license is Apache-2.0. The module archive excludes the browser application and bridge.
