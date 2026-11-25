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
  Ok(patterns(n, clue, cap)) catch {
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
priv struct Search {
  h : Int32
  w : Int32
  domains : Array[Array[Int32]]
  limits : Limits
  metrics : Metrics
  mut solutions : Int32
  mut first : Array[Int32]?
}

///|
fn Search::sweep(
  self : Search,
  grid : Array[Int32],
  line : Int32,
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
  let mut all = (1 << n) - 1
  let mut any = 0
  let mut found = false
  for mask in self.domains[line] {
    if self.metrics.scans >= self.limits.scans {
      raise Exhausted
    }
    self.metrics.scans += 1
    if (mask & black) == black && (mask & white) == 0 {
      all = all & mask
      any = any | mask
      found = true
    }
  }
  if !found {
    return -1
  }
  let mut forced = 0
  for i in 0..<n {
    let at = offset + i * step
    let bit = 1 << i
    if grid[at] < 0 {
      if (all & bit) != 0 {
        grid[at] = 1
        forced += 1
      } else if (any & bit) == 0 {
        grid[at] = 0
        forced += 1
      }
    }
  }
  forced
}

///|
fn Search::visit(
  self : Search,
  grid : Array[Int32],
  depth : Int32,
) -> Unit raise Stop {
  if self.metrics.nodes >= self.limits.nodes || depth > 256 {
    raise Exhausted
  }
  self.metrics.nodes += 1
  while true {
    let mut forced = 0
    self.metrics.rounds += 1
    for line in 0..<(self.h + self.w) {
      let added = self.sweep(grid, line)
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
  for i, v in grid {
    if v < 0 {
      at = i
      break
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
    let before = self.solutions
    self.visit(branch, depth + 1)
    if self.solutions == before {
      self.metrics.backtracks += 1
    }
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
    metrics,
    solutions: 0,
    first: None,
  }
  let status = try {
    if h < 1 || w < 1 || h > 30 || w > 30 {
      raise InvalidInput
    }
    for line in 0..<(h + w) {
      let (n, clue) = if line < h {
        (w, rows[line])
      } else {
        (h, cols[line - h])
      }
      let domain = patterns(n, clue, limits.candidates - metrics.patterns)
      metrics.patterns += domain.length()
      if domain.length() > metrics.largest {
        metrics.largest = domain.length()
      }
      search.domains.push(domain)
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
  { status, first: search.first, metrics, }
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
) -> Result[Generated, GenerationError] {
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
    let grid = Array::makei(n * n, _ => {
      state = state ^ (state << 13)
      state = state ^ (state >> 17)
      state = state ^ (state << 5)
      if state % 100U < density.to_uint() {
        1
      } else {
        0
      }
    })
    let (rows, cols) = clues(grid, n, n)
    let result = solve(rows, cols, limits)
    match result.status {
      Unique => return Ok({ rows, cols, grid, attempts: attempt, result, })
      NoSolution | Invalid => return Err(Invariant)
      _ => ()
    }
  }
  Err(AttemptLimit)
}
