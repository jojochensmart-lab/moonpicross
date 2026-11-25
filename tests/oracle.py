"""Independent enumeration oracle. Run from module root before moon test."""
from collections import Counter
from itertools import product
from random import Random
from pathlib import Path

def clue(line):
    return tuple(len(run) for run in "".join(map(str, line)).split("0") if run)

def signature(bits, n):
    rows = tuple(clue(bits[i:i+n]) for i in range(0, n*n, n))
    cols = tuple(clue(bits[i::n]) for i in range(n))
    return rows, cols

def count(rows, cols, n):
    domains = {}
    for line in product((0,1), repeat=n):
        domains.setdefault(clue(line), []).append(line)
    matches = 0
    for grid in product(*(domains.get(row, []) for row in rows)):
        if tuple(clue(c) for c in zip(*grid)) == cols:
            matches += 1
            if matches == 2:
                break
    return matches

def mbt(data):
    return str([list(x) for x in data])

all_counts = Counter(signature(bits, 3) for bits in product((0,1), repeat=9))
choices = [(), (1,), (2,), (3,), (1,1)]
codes = [min(2, all_counts[(v[:3], v[3:])]) for v in product(choices, repeat=6)]
# RLE is unnecessary; emit compact independent lookup code as raw strings.
lines = ['///|', 'test "all 15625 3x3 line-valid clue assignments" {',
         '  let choices = [[], [1], [2], [3], [1,1]]', '  let expected =']
digits = "".join(map(str, codes))
lines += ['    #|' + digits[i:i+125] for i in range(0, len(digits), 125)]
lines += [
 '  let mut index = 0',
 '  for ch in expected {',
 "    if ch == '\\n' { continue }",
 '    let keys = Array::makei(6, k => choices[(index / [3125,625,125,25,5,1][k]) % 5])',
 '    let result = @core.solve([keys[0], keys[1], keys[2]], [keys[3], keys[4], keys[5]], @core.Limits::default())',
 "    let expected_status : @core.Status = if ch == '0' { NoSolution } else if ch == '1' { Unique } else { Multiple }",
 '    assert_eq(result.status, expected_status, msg=index.to_string())',
 '    index += 1',
 '  }',
 '  assert_eq(index, 15625)',
 '}',
 '///|',
 'test "independent 4x4 and 5x5 oracle" {',
]
rng = Random(20261125)
stats = {}
for n in (4,5):
    out = Counter()
    for density in (15,35,50,65,85):
        for k in range(12):
            bits = [int(rng.randrange(100)<density) for _ in range(n*n)]
            rows, cols = signature(bits,n)
            if k % 4 == 0:
                cols = ((),)*n if any(rows) else ((1,),)*n
            status = count(rows,cols,n)
            out[status] += 1
            expected = ["NoSolution","Unique","Multiple"][status]
            lines.append(f"  assert_eq(@core.solve({mbt(rows)}, {mbt(cols)}, @core.Limits::default()).status, @core.Status::{expected})")
    stats[n] = dict(out)
lines += ['}']
Path("core/oracle_test.mbt").write_text("\n".join(lines)+"\n", encoding="utf-8")
print("3x3",dict(Counter(codes)),"4x4 / 5x5",stats)
