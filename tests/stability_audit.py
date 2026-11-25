"""Independently count solutions from released-style witnesses using line-domain bitsets."""
import csv
import functools
import itertools
import statistics
import sys
from collections import defaultdict


def clue(line):
    return tuple(len(run) for run in line.split("0") if run)


@functools.lru_cache(maxsize=2048)
def supports(width, runs):
    # Choose a nondecreasing allocation of the available spaces between runs.
    slack = width - sum(runs) - max(0, len(runs) - 1)
    placements = []
    for offsets in itertools.combinations_with_replacement(range(slack + 1), len(runs)):
        position = 0
        mask = 0
        for offset, length in zip(offsets, runs):
            mask |= ((1 << length) - 1) << (position + offset)
            position += length + 1
        placements.append(mask)
    bits = [0] * width
    for candidate, mask in enumerate(placements):
        while mask:
            bit = mask & -mask
            bits[bit.bit_length() - 1] |= 1 << candidate
            mask ^= bit
    return (1 << len(placements)) - 1, tuple(bits)


def count_solutions(rows, cols):
    """AC on intersecting line domains, then branch on a whole line pattern."""
    h, w = len(rows), len(cols)
    domains = [supports(w, item) for item in rows] + [supports(h, item) for item in cols]
    edges = [
        [(h + x, x, y) for x in range(w)] for y in range(h)
    ] + [
        [(y, y, x) for y in range(h)] for x in range(w)
    ]

    def search(active, dirty, remaining):
        while dirty:
            line = dirty.pop()
            domain = active[line]
            if not domain:
                return 0
            for other, here, there in edges[line]:
                on = domains[line][1][here]
                if domain & on and domain & ~on:
                    continue
                other_on = domains[other][1][there]
                narrowed = active[other] & (other_on if domain & on else ~other_on)
                if narrowed != active[other]:
                    active[other] = narrowed
                    dirty.add(other)
        choices = [(mask.bit_count(), i) for i, mask in enumerate(active) if mask.bit_count() > 1]
        if not choices:
            return 1
        _, line = min(choices)
        candidates = active[line]
        total = 0
        while candidates and total < remaining:
            bit = candidates & -candidates
            candidates ^= bit
            branch = active.copy()
            branch[line] = bit
            total += search(branch, {line}, remaining - total)
        return total

    return search([domain for domain, _ in domains], set(range(h + w)), 2)


def check_reference():
    counts = defaultdict(int)
    for values in itertools.product("01", repeat=9):
        grid = "".join(values)
        rows = tuple(clue(grid[i:i+3]) for i in (0, 3, 6))
        cols = tuple(clue(grid[i::3]) for i in range(3))
        counts[rows, cols] += 1
    hints = ((), (1,), (2,), (3,), (1, 1))
    for entries in itertools.product(hints, repeat=6):
        key = entries[:3], entries[3:]
        assert count_solutions(*key) == min(2, counts.get(key, 0)), key


def audit(path):
    check_reference()
    groups = defaultdict(list)
    verified = {}
    with open(path, encoding="utf-8-sig", newline="") as source:
        for tag, group, width, seed, status, attempts, budget, multiple, nodes, ms, grid in list(csv.reader(source))[1:]:
            n = int(width)
            if status == "Unique":
                assert len(grid) == n * n and set(grid) <= {"0", "1"}
                if grid not in verified:
                    rows = tuple(clue(grid[y:y+n]) for y in range(0, len(grid), n))
                    cols = tuple(clue(grid[x::n]) for x in range(n))
                    verified[grid] = count_solutions(rows, cols)
                assert verified[grid] == 1, (group, n, seed)
            else:
                assert status == "AttemptLimit" and int(attempts) == 24 and not grid
            groups[group, n].append((int(seed), status, int(attempts), int(budget), int(multiple), int(nodes), float(ms), grid))
    print("| Cohort | Size | Verified | Duplicates | Density min–max | Mean ms / seed | Mean attempts | Failed-seed budget / multiple attempts |")
    print("|---|---:|---:|---:|---:|---:|---:|---:|")
    for (group, n), cases in groups.items():
        expected = 100 if group == "original" and n == 20 else 200
        start = 10001 if group == "new" else 1
        assert sorted(c[0] for c in cases) == list(range(start, start + expected))
        boards = [c[-1] for c in cases if c[1] == "Unique"]
        failed = [c for c in cases if c[1] == "AttemptLimit"]
        density = [board.count("1") / len(board) * 100 for board in boards]
        print(f"| {group} | {n} | {len(boards)}/{len(cases)} | {len(boards)-len(set(boards))}/{len(boards)} | "
              f"{min(density):.1f}%–{max(density):.1f}% | {statistics.mean(c[6] for c in cases):.2f} | "
              f"{statistics.mean(c[2] for c in cases):.2f} | {sum(c[3] for c in failed)} / {sum(c[4] for c in failed)} |")


if __name__ == "__main__":
    audit(sys.argv[1])
