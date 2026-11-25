import { spawnSync } from "node:child_process";
import { copyFileSync } from "node:fs";
import { fileURLToPath } from "node:url";

const root = fileURLToPath(new URL("../", import.meta.url));
const result = spawnSync("moon", ["build", "webapi", "--target", "js", "--release"], {
  cwd: root,
  stdio: "inherit"
});
if (result.error) throw result.error;
if (result.status !== 0) process.exit(result.status ?? 1);
copyFileSync(new URL("../_build/js/release/build/webapi/webapi.js", import.meta.url),
  new URL("../studio/engine.js", import.meta.url));
