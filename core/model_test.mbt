///|
test "puzzle JSON round trips and refuses invalid input" {
  let puzzle : @core.Puzzle = { version: 1, rows: [[1]], cols: [[1]], }
  assert_eq(@core.Puzzle::from_json(puzzle.to_json().stringify()), Ok(puzzle))
  assert_eq(
    @core.Puzzle::from_json("{\"version\":2,\"rows\":[[]],\"cols\":[[]]}"),
    Err(@core.PuzzleError::UnsupportedVersion),
  )
  assert_eq(
    @core.Puzzle::from_json("{\"version\":1,\"rows\":[[2]],\"cols\":[[]]}"),
    Err(@core.PuzzleError::InvalidClue),
  )
  assert_eq(@core.Puzzle::from_json("{"), Err(@core.PuzzleError::InvalidFormat))
  assert_eq(
    @core.Puzzle::from_grid({ height: 1, width: 1, cells: [Unknown], }),
    Err(@core.PuzzleError::IncompleteGrid),
  )
}

///|
test "trace records forced moves and budgets partial traces" {
  let puzzle : @core.Puzzle = { version: 1, rows: [[1]], cols: [[1]], }
  let result = puzzle.solve(@core.Limits::default(), trace=10).unwrap()
  assert_eq(result.steps[0].kind, "row")
  assert_eq(result.steps[0].candidates, 1)
  assert_eq(result.steps[0].indices, [0])
  assert_eq(result.steps[0].values, [1])
  let limited = puzzle.solve(@core.Limits::default(), trace=1).unwrap()
  assert_eq(limited.steps.length(), 1)
  assert_true(limited.trace_truncated)
}
