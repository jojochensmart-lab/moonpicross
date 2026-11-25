# Release and verification

- Core version 0.1.0 is on [Mooncakes](https://mooncakes.io/docs/jojochensmart-lab/moonpicross).
- Browser Studio is public on [GitHub Pages](https://jojochensmart-lab.github.io/moonpicross/).
- The offline ZIP is attached to [v0.1.0](https://github.com/jojochensmart-lab/moonpicross/releases/tag/v0.1.0).
- Actual platform, browser and downstream installation results are recorded in the [acceptance report](FINAL_RELEASE_ACCEPTANCE_REPORT.md).

## Releasing a new version

1. Agree on the SemVer change. Run the source tests, browser probe and package consumer checks. Review the archived LICENSE and README before publication.
2. Push the reviewed commit, confirm Linux and Windows CI, and run the Pages probe against the deployed site.
3. Confirm the new release tag and registry version are unused. Check the authorized account and module namespace. Validate the archive through moon publish --dry-run where supported. Publish only the intended version.
4. Verify the public registry page and add the exact version in a new project with no local module override. Run check, test and both examples. Confirm that the public Release tag points to the intended code.
