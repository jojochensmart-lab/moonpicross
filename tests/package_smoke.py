"""Smoke-test the local Mooncakes ZIP as a dependency; performs no publish."""
import re
import shutil
import subprocess
import tempfile
from pathlib import Path
from zipfile import ZipFile
root = Path(__file__).resolve().parents[1]
version = re.search(r'(?m)^version = "([^"]+)"', (root / "moon.mod").read_text()).group(1)
archive = root / f"_build/publish/jojochensmart-lab-moonpicross-{version}.zip"
workspace = Path(tempfile.mkdtemp(prefix="consumer-", dir=root / "_build"))
lib = workspace / "library"
consumer = workspace / "consumer"
consumer.mkdir()
with ZipFile(archive) as package:
    assert package.testzip() is None
    assert "core/solver.mbt" in package.namelist()
    assert "shenbaoshu.md" not in package.namelist()
    assert not any(p.startswith(("studio/", "webapi/", "scripts/")) or p.endswith(".log") for p in package.namelist())
    package.extractall(lib)
(workspace / "moon.work").write_text('members = ["./library", "./consumer"]\n', encoding="utf-8")
(consumer / "moon.mod").write_text(f'name = "local/picross-consumer"\nimport {{ "jojochensmart-lab/moonpicross@{version}" }}\n', encoding="utf-8")
shutil.copy(root / "examples/solve/moon.pkg", consumer)
shutil.copy(root / "examples/solve/main.mbt", consumer)
for args in (("check", "--target", "wasm-gc"), ("run", "consumer", "--target", "wasm-gc")):
    result = subprocess.run(["moon", *args], cwd=workspace, text=True, capture_output=True, encoding="utf-8", errors="replace")
    if result.returncode:
        raise SystemExit(result.stdout + result.stderr)
assert "Unique" in result.stdout and "#####" in result.stdout, result.stdout
print("Packaged core: independent downstream import and unique solve PASS")
