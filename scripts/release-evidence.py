"""Build independently verifiable release bundles and reconcile their ZIP contents."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import shutil
import subprocess
import sys
import tempfile
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tests"))
from release_zip import canonicalize, compare, normalized, read_zip  # noqa: E402

STUDIO = ("studio/index.html", "studio/app.js", "studio/styles.css", "studio/engine.js", "LICENSE")
KINDS = ("release", "source", "studio")
SCRIPTS = ("scripts/release-evidence.py", "scripts/build-studio.mjs", "tests/release_zip.py",
           "tests/package_smoke.py", ".moonignore", ".github/workflows/ci.yml")


def sha(data):
    return hashlib.sha256(data).hexdigest()


def archive_manifest(path):
    members, metadata, _ = read_zip(path)
    return {"name": path.name, "sha256": sha(path.read_bytes()), "count": len(members),
            "members": [{"path": name, "sha256": sha(data), "size": len(data),
                         "normalized_sha256": sha(normalized(name, data))}
                        for name, data in sorted(members.items())]}


def exercise_determinism(raw, target):
    members, _, _ = read_zip(raw)
    with tempfile.TemporaryDirectory() as temp:
        variant = Path(temp) / "reordered.zip"
        repeat = Path(temp) / "repeat.zip"
        control = Path(temp) / "control.zip"
        with ZipFile(variant, "x") as output:
            for name, data in reversed(list(members.items())):
                info = ZipInfo(name, (2001, 1, 1, 0, 0, 0))
                info.create_system = 0
                info.external_attr = 0x80
                output.writestr(info, data, compress_type=ZIP_DEFLATED, compresslevel=1)
        canonicalize(raw, repeat)
        canonicalize(variant, control)
        expected = target.read_bytes()
        if repeat.read_bytes() != expected or control.read_bytes() != expected:
            raise ValueError("Deterministic ZIP repetition or metadata perturbation diverged")


def prepare(args):
    args.out.mkdir(parents=True, exist_ok=False)
    prefix = args.label + "-v020-"
    raw, source, studio = [args.out / (prefix + kind + ".zip") for kind in KINDS]
    shutil.copyfile(args.raw, raw)
    canonicalize(raw, source)
    exercise_determinism(raw, source)
    with tempfile.TemporaryDirectory() as temp:
        assets = Path(temp) / "studio-input.zip"
        with ZipFile(assets, "x") as output:
            for name in STUDIO:
                output.write(ROOT / name, name)
        canonicalize(assets, studio)

    def command(*argv):
        return subprocess.check_output(argv, cwd=ROOT, text=True).strip()

    commit = command("git", "rev-parse", "HEAD")
    if os.environ.get("GITHUB_SHA", commit) != commit:
        raise ValueError("Checkout SHA differs from the workflow SHA")
    evidence = {
        "schema": 1, "commit": commit, "label": args.label,
        "moon": command("moon", "version").splitlines()[0],
        "node": command("node", "--version"),
        "python": platform.python_version(), "os": platform.system(),
        "os_release": platform.release(), "arch": platform.machine(),
        "runner_image": os.environ.get("ImageOS"), "runner_image_version": os.environ.get("ImageVersion"),

        "determinism": "same input repeated and reversed order, timestamp, permissions and compression perturbed",
        "archives": {kind: archive_manifest(path) for kind, path in zip(KINDS, (raw, source, studio))},
    }
    # The provenance hashes use Git blob bytes, independent of checkout EOL.
    evidence["scripts"] = {}
    for name in SCRIPTS:
        blob = subprocess.check_output(["git", "show", f"HEAD:{name}"], cwd=ROOT)
        if blob.replace(b"\r\n", b"\n") != (ROOT / name).read_bytes().replace(b"\r\n", b"\n"):
            raise ValueError(f"Uncommitted release script: {name}")
        evidence["scripts"][name] = sha(blob)
    (args.out / (prefix + "manifest.json")).write_text(json.dumps(evidence, indent=2) + "\n", encoding="utf-8")
    print(f"Prepared {args.label}: {source.name} {evidence['archives']['source']['sha256']}")


def bundle(directory, label):
    manifest = directory / f"{label}-v020-manifest.json"
    value = json.loads(manifest.read_text(encoding="utf-8"))
    if value["schema"] != 1 or value["label"] != label:
        raise ValueError(f"Unexpected manifest for {label}")
    for kind in KINDS:
        path = directory / f"{label}-v020-{kind}.zip"
        if archive_manifest(path) != value["archives"][kind]:
            raise ValueError(f"Archive disagrees with the manifest: {path.name}")
    return value


def reconcile(args):
    locations = {"windows": args.windows, "linux": args.linux, "local": args.local}
    reports = {}
    missing = []
    for label, directory in locations.items():
        for suffix in ("manifest.json", *(kind + ".zip" for kind in KINDS)):
            if not (directory / f"{label}-v020-{suffix}").is_file():
                missing.append(f"{label}/{label}-v020-{suffix}")
    if missing:
        return {"classification": "C", "missing": missing}
    try:
        manifests = {label: bundle(path, label) for label, path in locations.items()}
    except (OSError, KeyError, ValueError) as error:
        return {"classification": "C", "reason": str(error)}
    basis = manifests["windows"]
    if any(value["commit"] != basis["commit"] or value["scripts"] != basis["scripts"]
           for value in manifests.values()) or manifests["linux"]["moon"] != basis["moon"]:
        return {"classification": "C", "reason": "Commit, script provenance, or the remote Moon toolchain differs",
                "builds": {label: {"commit": m["commit"], "moon": m["moon"]} for label,m in manifests.items()}}
    for kind in KINDS:
        cases = {}
        for left, right in (("windows", "linux"), ("windows", "local"), ("linux", "local")):
            detail = compare(locations[left] / f"{left}-v020-{kind}.zip",
                             locations[right] / f"{right}-v020-{kind}.zip")
            for item in detail["files"]:
                item["difference"] = ("none" if item["content_equal"] else
                                      "lf-crlf-only" if item["equal_after_lf"] else
                                      "compiled-studio-output" if item["path"] == "studio/engine.js" else
                                      "unexplained-content")
            same = not (detail["left_only"] or detail["right_only"] or
                        any(not row["content_equal"] for row in detail["files"]))
            detail["classification"] = "A" if same else "B"
            detail["zip_bytes_equal"] = detail["left_sha256"] == detail["right_sha256"]
            cases[f"{left}-vs-{right}"] = detail
        reports[kind] = cases
    return {"classification": "A" if all(p["classification"]=="A" for cases in reports.values()
                                         for p in cases.values()) else "B",
            "local_moon_matches_runners": manifests["local"]["moon"] == basis["moon"],
            "comparisons": reports}


def verify_studio(args):
    with tempfile.TemporaryDirectory() as temp:
        stage = Path(temp)
        members, _, _ = read_zip(args.zip)
        if set(members) != set(STUDIO):
            raise ValueError("Unexpected Studio archive contents")
        for name, data in members.items():
            path = stage / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(data)
        scripts = stage / "scripts"
        scripts.mkdir()
        for name in ("test-studio.mjs", "test-studio-files.mjs"):
            shutil.copyfile(ROOT / "scripts" / name, scripts / name)
        subprocess.run(["node","scripts/test-studio.mjs"], cwd=stage, check=True)
        subprocess.run(["node","scripts/test-studio-files.mjs"], cwd=stage, check=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="action", required=True)
    p = sub.add_parser("prepare")
    p.add_argument("--label", choices=("windows", "linux", "local"), required=True)
    p.add_argument("--raw", type=Path, required=True)
    p.add_argument("--out", type=Path, required=True)
    c = sub.add_parser("compare")
    for label in ("windows", "linux", "local"):
        c.add_argument("--" + label, type=Path, required=True)
    s = sub.add_parser("verify-studio")
    s.add_argument("zip", type=Path)
    args = parser.parse_args()
    if args.action == "prepare":
        prepare(args)
    elif args.action == "verify-studio":
        verify_studio(args)
    else:
        print(json.dumps(reconcile(args), indent=2))
