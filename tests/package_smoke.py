"""Inspect the candidate archive and compile a fresh consumer of its extracted core."""
import argparse
import hashlib
import re
import shutil
import stat
import subprocess
import tempfile
from pathlib import Path, PurePosixPath
from zipfile import ZipFile

root = Path(__file__).resolve().parents[1]
manifest = (root / "moon.mod").read_text(encoding="utf-8")
version = re.search(r'(?m)^version = "([^"]+)"', manifest).group(1)
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--canonical", type=Path, help="Verify a canonical source ZIP with LF-normalized text")
args = parser.parse_args()
archive = args.canonical or root / f"_build/publish/jojochensmart-lab-moonpicross-{version}.zip"
workspace = Path(tempfile.mkdtemp(prefix="consumer-", dir=root / "_build"))
lib, consumer = workspace / "library", workspace / "consumer"
consumer.mkdir()
required = {"LICENSE", "README.md", "moon.mod", "core/solver.mbt",
            "examples/solve/main.mbt", "examples/unique/main.mbt", "examples/generate/main.mbt"}
top_files = {"README.md", "LICENSE", "moon.mod", "CHANGELOG.md", "CONTRIBUTING.md"}
source_dirs = {"core", "demo", "examples", "docs", "tests"}
sensitive = [
    re.compile(r"(?i)(?<![\w/])[A-Z]:[/\\]|/(?:Users|home|tmp)/[\w.-]+/"),
    re.compile(r"github_pat_[A-Za-z0-9_]{20,}|gh[pousr]_[A-Za-z0-9]{20,}|-----BEGIN [A-Z ]*PRIVATE KEY-----"),
    re.compile(r"(?<!\d)1[3-9]\d{9}(?!\d)"),
    re.compile(r'(?i)(?:api[_-]?key|token|password)\s*[:=]\s*["\x27][^"\x27\r\n]{12,}'),
]
with ZipFile(archive) as package:
    assert package.testzip() is None, "CRC validation failed"
    names = package.namelist()
    assert len(names) == len(set(names)) and required <= set(names)
    for entry in package.infolist():
        name = PurePosixPath(entry.filename)
        assert not name.is_absolute() and ".." not in name.parts and "\\" not in entry.filename
        assert not stat.S_ISLNK(entry.external_attr >> 16), f"Unexpected symbolic link: {name}"
        assert str(name) in top_files or (
            name.parts[0] in source_dirs and name.suffix in {".mbt", ".md", ".py", ".pkg"}
        ), f"Unexpected package entry: {name}"
        content = package.read(entry).decode("utf-8-sig")
        if str(name) != "tests/package_smoke.py":
            assert not any(pattern.search(content) for pattern in sensitive), f"Sensitive pattern in {name}"
    for name in ("README.md", "LICENSE", "moon.mod"):
        expected = (root / name).read_bytes()
        if args.canonical:
            expected = expected.replace(b"\r\n", b"\n")
        assert package.read(name) == expected, f"Archive mismatch: {name}"
    for field, expected in {"name": "jojochensmart-lab/moonpicross", "version": version,
                            "license": "Apache-2.0",
                            "repository": "https://github.com/jojochensmart-lab/moonpicross"}.items():
        assert f'{field} = "{expected}"' in manifest, field
    package.extractall(lib)
print(f"ZIP: {len(names)} files; SHA256 {hashlib.sha256(archive.read_bytes()).hexdigest()}")

(workspace / "moon.work").write_text('members = ["./library", "./consumer"]\n', encoding="utf-8")
(consumer / "moon.mod").write_text(
    f'name = "local/picross-consumer"\nimport {{ "jojochensmart-lab/moonpicross@{version}" }}\n', encoding="utf-8"
)
shutil.copy(root / "examples/solve/moon.pkg", consumer)
(consumer / "main.mbt").write_text('''///|
fn main {
  let source = "{\\"version\\":1,\\"rows\\":[[1]],\\"cols\\":[[1]]}"
  let puzzle = @core.Puzzle::from_json(source).unwrap()
  let limits = @core.Limits::default()
  let unique = puzzle.solve(limits).unwrap()
  guard unique.status is @core.Unique && unique.first == Some([1]) else { abort("solve") }
  let config : @core.GenerationConfig = {
    size: 5, seed: 7U, density: 45, attempts: 24, limits, level: None,
  }
  guard config.run() is Ok(generated) && generated.result.status is @core.Unique else { abort("generation") }
  let clues = [[1], [1]]
  let limited = @core.solve_bounded(clues, clues, limits, max_depth=0)
  guard limited.status is @core.Budget else { abort("budget") }
  println("consumer checks passed")
}
''', encoding="utf-8")
for args in (("check", "--target", "wasm-gc"), ("run", "consumer", "--target", "wasm-gc"),
             ("run", "consumer", "--target", "js")):
    result = subprocess.run(["moon", *args], cwd=workspace, text=True, capture_output=True,
                            encoding="utf-8", errors="replace", timeout=60)
    if result.returncode:
        raise SystemExit(result.stdout + result.stderr)
    if args[0] == "run":
        assert "consumer checks passed" in result.stdout, result.stdout
print("Packaged core: isolated JSON, solve, uniqueness, generation and Budget passed (Wasm GC and JS)")
