# Open-source compliance

The project is distributed under Apache-2.0. The MoonBit code, browser UI, Python oracle and sample data were authored in this workspace. The oracle generates complete small-board grids and derives expected clues by direct enumeration. No puzzle artwork or level packs are bundled.

The core uses the MoonBit standard library. The Studio uses platform HTML, CSS and JavaScript plus a compiler-generated bridge. Python and Node.js are development tools, with no extra installed packages required by the verifiers. The workflow references GitHub-maintained checkout, setup-python and setup-node actions and tools distributed by MoonBit. The Windows runner adds the MIT-licensed msvc-dev-cmd action to load its existing toolchain environment. [Runner action](https://github.com/ilammy/msvc-dev-cmd)

| Reference | Observed license and use |
|---|---|
| Picross Harbor 2026 | Subproject license unconfirmed. Inspected to assess overlap; no files incorporated. [Source](https://github.com/bobzhang/games/tree/main/picross_harbor_2026) |
| ljiang9/nonogram | MIT. Reviewed row placement, propagation and generation behavior; no files incorporated. [Source](https://github.com/ljiang9/nonogram) |
| simon-frankau/nonogram-solver | MIT. Reviewed row constraints and enumeration for comparison; no files incorporated. [Source](https://github.com/simon-frankau/nonogram-solver) |
| monkeyArms/nonogram and timonkobusch/nonogram | MIT. Reviewed browser and trace feature overlap; no files incorporated. [JavaScript](https://github.com/monkeyArms/nonogram) · [TypeScript](https://github.com/timonkobusch/nonogram) |
| moonpeg | MIT. Related example of budget and certificate APIs for a different puzzle; no files incorporated. [Source](https://github.com/kekeshuo/moonpeg) |

Apache-2.0 license text ships in the archive. The 0.2.0 manifest has no third-party runtime dependencies. The canonical ZIP script uses Python standard-library modules. The license appendix retains the generic Apache notice template. The audit compares LICENSE byte for byte before normalization. Before accepting contributions or adding external assets, record provenance and carry forward any notices required by their licenses.

GitHub Pages uses the official configure-pages, upload-pages-artifact and deploy-pages actions. The public project license and the registry SPDX identifier are Apache-2.0. [Pages workflow](https://github.com/jojochensmart-lab/moonpicross/blob/077e40d84e68c9dac353fb80f49d90bf90680ae4/.github/workflows/pages.yml) · [Published module](https://mooncakes.io/docs/jojochensmart-lab/moonpicross)
