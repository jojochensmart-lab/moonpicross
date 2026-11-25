///|
fn main {
  let cases = [
    ([[1]], [[1]], @core.Status::Unique),
    ([[1]], [[]], @core.Status::NoSolution),
    ([[1], [1]], [[1], [1]], @core.Status::Multiple),
  ]
  for (rows, cols, expected) in cases {
    let puzzle : @core.Puzzle = { version: 1, rows, cols, }
    let result = puzzle.solve(@core.Limits::default()).unwrap()
    guard result.status == expected else {
      abort("Unexpected uniqueness result")
    }
    println(@debug.to_string(result.status))
  }
}
