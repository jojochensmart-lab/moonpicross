///|
pub(all) enum Status {
  NoSolution
  Unique
  Multiple
  Budget
  Invalid
} derive(Debug, Eq)

///|
pub(all) struct Limits {
  candidates : Int32
  nodes : Int32
  scans : Int32
}

///|
pub fn Limits::default() -> Limits {
  { candidates: 300000, nodes: 5000, scans: 5000000, }
}

///|
pub(all) struct Metrics {
  mut patterns : Int32
  mut largest : Int32
  mut rounds : Int32
  mut nodes : Int32
  mut backtracks : Int32
  mut scans : Int32
  forced_by_round : Array[Int32]
}

///|
pub(all) struct SolveResult {
  status : Status
  first : Array[Int32]?
  steps : Array[SolveStep]
  trace_truncated : Bool
  metrics : Metrics
}

///|
priv suberror Stop {
  InvalidInput
  Exhausted
}

///|
fn patterns(
  n : Int32,
  clue : Array[Int32],
  cap : Int32,
) -> Array[Int32] raise Stop {
  if n < 1 || n > 30 || clue.length() > (n + 1) / 2 {
    raise InvalidInput
  }
  let suffix = Array::make(clue.length() + 1, 0)
  for i = clue.length() - 1; i >= 0; i = i - 1 {
    if clue[i] < 1 || clue[i] > n || suffix[i + 1] > n {
      raise InvalidInput
    }
    suffix[i] = clue[i] +
      suffix[i + 1] +
      (if i + 1 < clue.length() { 1 } else { 0 })
  }
  if suffix[0] > n {
    raise InvalidInput
  }
  let output = []
  place(n, clue, suffix, 0, 0, 0, cap, output)
  output
}

///|
fn place(
  n : Int32,
  clue : Array[Int32],
  suffix : Array[Int32],
  i : Int32,
  start : Int32,
  mask : Int32,
  cap : Int32,
  output : Array[Int32],
) -> Unit raise Stop {
  if i == clue.length() {
    if output.length() >= cap {
      raise Exhausted
    }
    output.push(mask)
    return
  }
  for at = start; at <= n - suffix[i]; at = at + 1 {
    let width = clue[i]
    place(
      n,
      clue,
      suffix,
      i + 1,
      at + width + 1,
      mask | (((1 << width) - 1) << at),
      cap,
      output,
    )
  }
}

///|
pub fn line_patterns(
  n : Int32,
  clue : Array[Int32],
  cap : Int32,
) -> Result[Array[Int32], Status] {
  Ok(patterns(n, clue, cap.min(300000))) catch {
    InvalidInput => Err(Invalid)
    Exhausted => Err(Budget)
  }
}

///|
pub fn clue_for(line : Array[Int32]) -> Array[Int32] {
  let result = []
  let mut run = 0
  for cell in line {
    if cell == 1 {
      run += 1
    } else if run > 0 {
      result.push(run)
      run = 0
    }
  }
  if run > 0 {
    result.push(run)
  }
  result
}

///|
pub fn clues(
  grid : Array[Int32],
  h : Int32,
  w : Int32,
) -> (Array[Array[Int32]], Array[Array[Int32]]) {
  (
    Array::makei(h, y => clue_for(Array::makei(w, x => grid[y * w + x]))),
    Array::makei(w, x => clue_for(Array::makei(h, y => grid[y * w + x]))),
  )
}

///|
priv struct LineState {
  black : Int32
  white : Int32
  survivors : Int32
}

///|
priv struct Search {
  h : Int32
  w : Int32
  domains : Array[Array[Int32]]
  limits : Limits
  depth_limit : Int32
  line_state : Array[LineState?]
  metrics : Metrics
  trace_limit : Int32
  steps : Array[SolveStep]
  mut trace_truncated : Bool
  mut solutions : Int32
  mut first : Array[Int32]?
}

///|
fn Search::sweep(
  self : Search,
  grid : Array[Int32],
  line : Int32,
  depth : Int32,
) -> Int32 raise Stop {
  let is_row = line < self.h
  let (n, offset, step) = if is_row {
    (self.w, line * self.w, 1)
  } else {
    (self.h, line - self.h, self.w)
  }
  let mut black = 0
  let mut white = 0
  for i in 0..<n {
    let cell = grid[offset + step * i]
    if cell == 1 {
      black = black | (1 << i)
    }
    if cell == 0 {
      white = white | (1 << i)
    }
  }
  // A mask key captures all inputs to this line, even across DFS siblings.
  if self.line_state[line] is Some(previous) &&
    previous.black == black &&
    previous.white == white {
    return 0
  }
  let mut all = (1 << n) - 1
  let mut any = 0
  let mut found = 0
  for mask in self.domains[line] {
    if self.metrics.scans >= self.limits.scans.min(5000000) {
      raise Exhausted
    }
    self.metrics.scans += 1
    if (mask & black) == black && (mask & white) == 0 {
      all = all & mask
      any = any | mask
      found += 1
    }
  }
  if found == 0 {
    self.record("contradiction", line, 0, [], [], depth)
    return -1
  }
  let mut forced = 0
  let indices = []
  let values = []
  for i in 0..<n {
    let at = offset + i * step
    let bit = 1 << i
    if grid[at] < 0 {
      if (all & bit) != 0 {
        grid[at] = 1
        forced += 1
        if self.trace_limit > 0 {
          indices.push(at)
          values.push(grid[at])
        }
      } else if (any & bit) == 0 {
        grid[at] = 0
        forced += 1
        if self.trace_limit > 0 {
          indices.push(at)
          values.push(grid[at])
        }
      }
    }
  }
  // Assigning cells common to all survivors leaves that same domain intact.
  self.line_state[line] = Some({
    black: all,
    white: ((1 << n) - 1) ^ any,
    survivors: found,
  })
  if forced > 0 {
    self.record(
      if is_row {
        "row"
      } else {
        "column"
      },
      line,
      found,
      indices,
      values,
      depth,
    )
  }
  forced
}

///|
fn Search::visit(
  self : Search,
  grid : Array[Int32],
  depth : Int32,
) -> Unit raise Stop {
  if self.metrics.nodes >= self.limits.nodes.min(5000) ||
    depth > self.depth_limit {
    raise Exhausted
  }
  self.metrics.nodes += 1
  while true {
    let mut forced = 0
    self.metrics.rounds += 1
    for line in 0..<(self.h + self.w) {
      let added = self.sweep(grid, line, depth)
      if added < 0 {
        self.metrics.forced_by_round.push(forced)
        return
      }
      forced += added
    }
    self.metrics.forced_by_round.push(forced)
    if forced == 0 {
      break
    }
  }
  let mut at = -1
  let mut best_small = 2147483647
  let mut best_large = 2147483647
  for i, v in grid {
    if v < 0 {
      let row = self.line_state[i / self.w].unwrap().survivors
      let col = self.line_state[self.h + i % self.w].unwrap().survivors
      // Prefer the smallest incident domain, breaking ties with the other.
      let small = row.min(col)
      let large = row.max(col)
      if small < best_small || (small == best_small && large < best_large) {
        best_small = small
        best_large = large
        at = i
      }
    }
  }
  if at < 0 {
    self.solutions += 1
    if self.first is None {
      self.first = Some(grid)
    }
    return
  }
  for v in 0..<2 {
    let branch = grid.copy()
    branch[at] = v
    self.record("branch", -1, 2, [at], [v], depth)
    let before = self.solutions
    self.visit(branch, depth + 1)
    if self.solutions == before {
      self.metrics.backtracks += 1
    }
    self.record("backtrack", -1, 0, [at], [v], depth)
    if self.solutions >= 2 {
      return
    }
  }
}

///|
pub fn solve(
  rows : Array[Array[Int32]],
  cols : Array[Array[Int32]],
  limits : Limits,
  trace~ : Int32 = 0,
) -> SolveResult {
  solve_bounded(rows, cols, limits, trace~, max_depth=256)
}

///|
/// Solve with an optional lower depth ceiling. The root has depth zero.
pub fn solve_bounded(
  rows : Array[Array[Int32]],
  cols : Array[Array[Int32]],
  limits : Limits,
  trace~ : Int32 = 0,
  max_depth~ : Int32 = 256,
) -> SolveResult {
  let h = rows.length()
  let w = cols.length()
  let metrics = {
    patterns: 0,
    largest: 0,
    rounds: 0,
    nodes: 0,
    backtracks: 0,
    scans: 0,
    forced_by_round: [],
  }
  let search = {
    h,
    w,
    domains: [],
    limits,
    depth_limit: max_depth.min(256),
    line_state: [],
    metrics,
    trace_limit: trace.max(0).min(2000),
    steps: [],
    trace_truncated: false,
    solutions: 0,
    first: None,
  }
  let status = try {
    if h < 1 ||
      w < 1 ||
      h > 30 ||
      w > 30 ||
      max_depth < 0 ||
      limits.nodes < 0 ||
      limits.scans < 0 ||
      limits.candidates < 0 {
      raise InvalidInput
    }
    for line in 0..<(h + w) {
      let (n, clue) = if line < h {
        (w, rows[line])
      } else {
        (h, cols[line - h])
      }
      let domain = patterns(
        n,
        clue,
        limits.candidates.min(300000) - metrics.patterns,
      )
      metrics.patterns += domain.length()
      if domain.length() > metrics.largest {
        metrics.largest = domain.length()
      }
      search.domains.push(domain)
      search.line_state.push(None)
    }
    search.visit(Array::make(h * w, -1), 0)
    match search.solutions {
      0 => NoSolution
      1 => Unique
      _ => Multiple
    }
  } catch {
    InvalidInput => Invalid
    Exhausted => Budget
  }
  search.record("finish", -1, search.solutions, [], [], 0)
  {
    status,
    first: search.first,
    metrics,
    steps: search.steps,
    trace_truncated: search.trace_truncated,
  }
}

///|
pub(all) struct Generated {
  rows : Array[Array[Int32]]
  cols : Array[Array[Int32]]
  grid : Array[Int32]
  attempts : Int32
  result : SolveResult
}

///|
pub(all) enum GenerationError {
  InvalidOptions
  AttemptLimit
  Invariant
} derive(Debug, Eq)

///|
pub fn generate(
  n : Int32,
  seed : UInt32,
  density : Int32,
  max_attempts : Int32,
  limits : Limits,
  target~ : String? = None,
  observe~ : (SolveResult) -> Unit = _ => (),
) -> Result[Generated, GenerationError] {
  if target is Some(level) &&
    level != "Easy" &&
    level != "Normal" &&
    level != "Hard" &&
    level != "Expert" {
    return Err(InvalidOptions)
  }
  if n < 1 ||
    n > 30 ||
    density < 0 ||
    density > 100 ||
    max_attempts < 1 ||
    max_attempts > 1000 {
    return Err(InvalidOptions)
  }
  let mut state = if seed == 0U { 1U } else { seed }
  for attempt in 1..<=max_attempts {
    let grid = Array::make(n * n, 0)
    let structured = n >= 15 && attempt >= 9 && attempt % 2 == 1
    let vertical = attempt % 4 == 1
    for i in 0..<(n * n) {
      state = state ^ (state << 13)
      state = state ^ (state >> 17)
      state = state ^ (state << 5)
      let mut threshold = density
      if structured && density > 0 && density < 100 {
        let neighbor = if vertical {
          if i >= n {
            i - n
          } else {
            -1
          }
        } else if i % n > 0 {
          i - 1
        } else {
          -1
        }
        if neighbor >= 0 {
          // Give runs a chance to form while keeping the configured density
          // as the expected marginal probability along the line.
          threshold = if grid[neighbor] == 1 {
            density + (100 - density) / 2
          } else {
            (density + 1) / 2
          }
        }
      }
      if state % 100U < threshold.reinterpret_as_uint() {
        grid[i] = 1
      }
    }
    let (rows, cols) = clues(grid, n, n)
    let result = solve(rows, cols, limits)
    observe(result)
    match result.status {
      Unique if target is None || target == Some(difficulty(result).level) =>
        return Ok({ rows, cols, grid, attempts: attempt, result, })
      Invalid => return Err(Invariant)
      _ => ()
    }
  }
  Err(AttemptLimit)
}

///|
fn Search::record(
  self : Search,
  kind : String,
  line : Int32,
  candidates : Int32,
  indices : Array[Int32],
  values : Array[Int32],
  depth : Int32,
) -> Unit {
  if self.trace_limit == 0 {
    return
  }
  if self.steps.length() >= self.trace_limit {
    self.trace_truncated = true
    return
  }
  self.steps.push({ kind, line, candidates, indices, values, depth, })
}

///|
pub extend Status with @debug.Debug::{to_repr}

///|
pub extend Status with Eq::{not_equal, equal}

///|
pub extend GenerationError with @debug.Debug::{to_repr}

///|
pub extend GenerationError with Eq::{not_equal, equal}
