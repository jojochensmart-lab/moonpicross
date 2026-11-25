///|
pub(all) enum Cell {
  Unknown
  Black
  White
} derive(Eq, Debug)

///|
pub(all) struct Grid {
  height : Int32
  width : Int32
  cells : Array[Cell]
} derive(Eq, Debug)

///|
pub type RowClue = Array[Int32]

///|
pub type ColumnClue = Array[Int32]

///|
pub(all) struct Puzzle {
  version : Int32
  rows : Array[RowClue]
  cols : Array[ColumnClue]
} derive(Eq, Debug, ToJson, FromJson)

///|
pub(all) enum PuzzleError {
  InvalidDimensions
  InvalidClue
  IncompleteGrid
  InvalidFormat
  UnsupportedVersion
} derive(Eq, Debug)

///|
pub fn Puzzle::validate(self : Puzzle) -> Result[Unit, PuzzleError] {
  if self.version != 1 {
    return Err(UnsupportedVersion)
  }
  let h = self.rows.length()
  let w = self.cols.length()
  if h < 1 || w < 1 || h > 30 || w > 30 {
    return Err(InvalidDimensions)
  }
  for row in self.rows {
    if !valid_line(w, row) {
      return Err(InvalidClue)
    }
  }
  for col in self.cols {
    if !valid_line(h, col) {
      return Err(InvalidClue)
    }
  }
  Ok(())
}

///|
fn valid_line(n : Int32, clue : Array[Int32]) -> Bool {
  if clue.length() > (n + 1) / 2 {
    return false
  }
  let mut total = 0
  for k in clue {
    if k < 1 || k > n {
      return false
    }
    total += k
  }
  total + (clue.length() - 1).max(0) <= n
}

///|
pub fn Puzzle::from_grid(grid : Grid) -> Result[Puzzle, PuzzleError] {
  let { height, width, cells, } = grid
  if height < 1 ||
    width < 1 ||
    height > 30 ||
    width > 30 ||
    cells.length() != height * width {
    return Err(InvalidDimensions)
  }
  let bits = []
  for cell in cells {
    match cell {
      Black => bits.push(1)
      White => bits.push(0)
      Unknown => return Err(IncompleteGrid)
    }
  }
  let (rows, cols) = clues(bits, height, width)
  Ok({ version: 1, rows, cols, })
}

///|
pub fn Puzzle::from_json(source : String) -> Result[Puzzle, PuzzleError] {
  if source.length() > 32768 {
    return Err(InvalidFormat)
  }
  let value = @json.parse(
    source,
    max_nesting_depth=8,
    reject_duplicate_keys=true,
  ) catch {
    _ => return Err(InvalidFormat)
  }
  let accepted = match
    (value.value("version"), value.value("rows"), value.value("cols")) {
    (Some(version), Some(rows), Some(cols)) =>
      json_integer(version) && json_lines(rows) && json_lines(cols)
    _ => false
  }
  if !accepted {
    return Err(InvalidFormat)
  }
  let puzzle : Puzzle = @json.from_json(value) catch {
    _ => return Err(InvalidFormat)
  }
  match puzzle.validate() {
    Ok(_) => Ok(puzzle)
    Err(e) => Err(e)
  }
}

///|
pub fn Puzzle::solve(
  self : Puzzle,
  limits : Limits,
  trace~ : Int32 = 0,
) -> Result[SolveResult, PuzzleError] {
  match self.validate() {
    Ok(_) => Ok(solve(self.rows, self.cols, limits, trace~))
    Err(e) => Err(e)
  }
}

///|
pub(all) struct SolveStep {
  kind : String
  line : Int32
  candidates : Int32
  indices : Array[Int32]
  values : Array[Int32]
  depth : Int32
} derive(ToJson)

///|
pub type SolverStats = Metrics

///|
fn json_integer(value : Json) -> Bool {
  match value.as_number() {
    Some(n) =>
      n >= -2147483648.0 && n <= 2147483647.0 && n == n.to_int().to_double()
    None => false
  }
}

///|
fn json_lines(value : Json) -> Bool {
  guard value.as_array() is Some(lines) else { return false }
  for line in lines {
    guard line.as_array() is Some(clues) else { return false }
    for clue in clues {
      if !json_integer(clue) {
        return false
      }
    }
  }
  true
}
