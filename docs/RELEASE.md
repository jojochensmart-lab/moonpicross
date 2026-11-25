# Release and verification

Mooncakes and the online and downloadable Studio still serve 0.1.0. The v0.2.0 code candidate is 077e40d84e68c9dac353fb80f49d90bf90680ae4. Its Windows and Linux jobs passed. This revision prepares the release documentation and archive tooling. [Published module](https://mooncakes.io/docs/jojochensmart-lab/moonpicross) · [Candidate CI](https://github.com/jojochensmart-lab/moonpicross/actions/runs/45604621651)

## Local packaging

~~~sh
moon package --list
python tests/package_smoke.py
python tests/release_zip.py canonicalize _build/publish/jojochensmart-lab-moonpicross-0.2.0.zip _build/moonpicross-0.2.0-source.zip
python tests/package_smoke.py --canonical _build/moonpicross-0.2.0-source.zip
~~~

Use a fresh canonical output path on each run. The script preserves every safe file entry, normalizes CRLF to LF for known UTF-8 source and documentation files, and fixes order, timestamp, mode and compression for the portable source ZIP. The regular MoonBit tool still creates the Mooncakes input. The canonical source ZIP is suitable as a separately identified offline source asset. It makes no assertion about the registry-generated archive or the browser build.

## After release authorization

1. Review the final diff and verify the release branch SHA. Run CI on that SHA. Preserve the existing v0.1.0 release.
2. Save the unmodified MoonBit archive from each release job as a downloadable artifact before the runner is removed. Retain the listed hash and canonical archive separately.
3. Compare paths, decompressed member hashes and ZIP attributes with python tests/release_zip.py compare. Run the isolated consumer on the exact archive selected for distribution.
4. Check the intended version and account before creating the approved release and registry entry. Verify registry availability and install the exact 0.2.0 version in a new project with no local workspace override. Run all three examples and the budget check. Verify any separately approved Pages deployment.

The source repository includes docs/V020_FINAL_RELEASE_CHECKLIST.md and docs/V020_ZIP_CONSISTENCY_AUDIT.md. The completed local freeze record and SHA256SUMS are generated under _build/v020-final-freeze/.
