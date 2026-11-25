"""Summarize two runs of the same MoonPicross benchmark."""
import csv
import math
import statistics
import sys
from pathlib import Path


def load(path):
    return [row for row in csv.reader(Path(path).read_text(encoding="utf-8-sig").splitlines())
            if len(row) >= 3 and row[1].isdigit()]


def solve_summary(rows, size):
    selected = [r for r in rows if r[:2] == ["solve", size]]
    times = sorted(float(r[7]) for r in selected)
    means = [statistics.mean(int(r[col]) for r in selected) for col in (4, 5, 6)]
    return [statistics.mean(times), statistics.median(times),
            times[math.ceil(len(times) * 0.95) - 1], *means,
            sum(r[3] == "Budget" for r in selected)]


before, after = map(load, sys.argv[1:])
assert [r[:3] for r in before] == [r[:3] for r in after]
print("| Size | Mean µs | Median µs | P95 µs | Mean nodes | Mean backtracks | Mean scans | Budget / 60 |")
print("|---|---:|---:|---:|---:|---:|---:|---:|")
for size in ("5", "10", "15", "20"):
    old, new = (solve_summary(rows, size) for rows in (before, after))
    print("| " + size + " | " + " | ".join(f"{a:.2f} → {b:.2f}" for a, b in zip(old, new)) + " |")
    pairs = [(a, b) for a, b in zip(before, after) if a[:2] == ["solve", size]]
    assert all(a[3] == b[3] or "Budget" in (a[3], b[3]) for a, b in pairs)
print()
print("| Size | Certified / seeds | Mean attempts / seed | Mean nodes / attempt | Mean ms / seed | Budget attempts |")
print("|---|---:|---:|---:|---:|---:|")
for size in ("5", "10", "15", "20"):
    a, b = (next(r for r in rows if r[:2] == ["survey", size]) for rows in (before, after))
    assert a[3] == a[4] and b[3] == b[4] and a[2] == b[2]
    print(f"| {size} | {a[3]} → {b[3]} / {b[2]} | {int(a[5])/int(a[2]):.2f} → {int(b[5])/int(b[2]):.2f} | "
          f"{float(a[6]):.2f} → {float(b[6]):.2f} | {float(a[7]):.2f} → {float(b[7]):.2f} | {a[8]} → {b[8]} |")
