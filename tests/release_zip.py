"""Audit Moon package ZIPs or build a deterministic source-distribution ZIP."""
import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import stat
from zipfile import ZIP_STORED, ZipFile, ZipInfo

TEXT_FILES = {"LICENSE", "README.md", "moon.mod", "CHANGELOG.md", "CONTRIBUTING.md"}
TEXT_SUFFIXES = {".mbt", ".md", ".pkg", ".py"}


def sha(data):
    return hashlib.sha256(data).hexdigest()


def normalized(name, data):
    path = PurePosixPath(name)
    if name in TEXT_FILES or path.suffix in TEXT_SUFFIXES:
        data.decode("utf-8-sig", errors="strict")
        return data.replace(b"\r\n", b"\n")
    return data


def read_zip(path):
    entries = {}
    metadata = {}
    with ZipFile(path) as archive:
        if archive.testzip() is not None:
            raise ValueError(f"Invalid CRC in {path}")
        for info in archive.infolist():
            name = info.filename
            member = PurePosixPath(name)
            if (not name or member.is_absolute() or member.as_posix() != name
                or ".." in member.parts or "\\" in name or ":" in name or info.is_dir()
                or stat.S_ISLNK(info.external_attr >> 16) or name in entries):
                raise ValueError(f"Unsafe or duplicate member: {name!r}")
            entries[name] = archive.read(info)
            metadata[name] = {
                "time": info.date_time, "compression": info.compress_type,
                "size": info.file_size, "compressed_size": info.compress_size,
                "flags": info.flag_bits, "host": info.create_system,
                "external_attr": info.external_attr, "internal_attr": info.internal_attr,
                "create_version": info.create_version, "extract_version": info.extract_version,
                "extra": info.extra.hex(), "comment": info.comment.hex(),
            }
        return entries, metadata, archive.comment.hex()


def compare(left, right):
    a, ma, ca = read_zip(left)
    b, mb, cb = read_zip(right)
    shared = sorted(a.keys() & b.keys())
    return {
        "left_sha256": sha(left.read_bytes()), "right_sha256": sha(right.read_bytes()),
        "left_count": len(a), "right_count": len(b),
        "left_only": sorted(a.keys() - b.keys()), "right_only": sorted(b.keys() - a.keys()),
        "entry_order_equal": list(a) == list(b), "archive_comments_equal": ca == cb,
        "files": [{
            "path": name, "left_sha256": sha(a[name]), "right_sha256": sha(b[name]),
            "content_equal": a[name] == b[name],
            "equal_after_lf": normalized(name, a[name]) == normalized(name, b[name]),
            "left_crlf": a[name].count(b"\r\n"), "right_crlf": b[name].count(b"\r\n"),
            "metadata_differences": {key: [ma[name][key], mb[name][key]]
                                     for key in ma[name] if ma[name][key] != mb[name][key]},
        } for name in shared],
    }


def canonicalize(source, destination):
    if source.resolve() == destination.resolve():
        raise ValueError("Use a separate destination so the Mooncakes input is preserved")
    contents, _, _ = read_zip(source)
    with ZipFile(destination, "x") as output:
        for name, data in sorted(contents.items()):
            info = ZipInfo(name, date_time=(1980, 1, 1, 0, 0, 0))
            info.create_system = 3
            info.external_attr = (stat.S_IFREG | 0o644) << 16
            info.compress_type = ZIP_STORED
            output.writestr(info, normalized(name, data))
    check, _, _ = read_zip(destination)
    if check != {name: normalized(name, data) for name, data in contents.items()}:
        raise ValueError("Output members do not match normalized source members")
    return sha(destination.read_bytes())


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    command = parser.add_subparsers(dest="action", required=True)
    for action in ("compare", "canonicalize"):
        sub = command.add_parser(action)
        sub.add_argument("source", type=Path)
        sub.add_argument("other", type=Path)
    args = parser.parse_args()
    if args.action == "compare":
        print(json.dumps(compare(args.source, args.other), indent=2))
    else:
        print(canonicalize(args.source, args.other))
