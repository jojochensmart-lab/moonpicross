///|
test "bounded inputs do not consume search budget or overflow" {
  let source = String::make(32769, ' ')
  assert_eq(
    @core.Puzzle::from_json(source),
    Err(@core.PuzzleError::InvalidFormat),
  )
  assert_eq(
    @core.Puzzle::from_json(
      "{\"version\":1,\"version\":2,\"rows\":[[]],\"cols\":[[]]}",
    ),
    Err(@core.PuzzleError::InvalidFormat),
  )
  assert_eq(
    @core.Puzzle::from_json("{\"version\":1,\"rows\":[[1.5]],\"cols\":[[1]]}"),
    Err(@core.PuzzleError::InvalidFormat),
  )
  let rows = Array::makei(31, _ => [])
  assert_eq(
    @core.solve(rows, [[]], @core.Limits::default()).status,
    @core.Status::Invalid,
  )
  let result = @core.solve([[1], [1]], [[1], [1]], {
    candidates: 100,
    nodes: 100,
    scans: 3,
  })
  assert_eq(result.status, @core.Status::Budget)
  assert_eq(result.metrics.scans, 3)
  let result = @core.solve([[1], [1]], [[1], [1]], {
    candidates: 100,
    nodes: 100,
    scans: 1000,
  })
  assert_eq(result.status, @core.Status::Multiple)
  assert_eq(result.metrics.nodes, 3)
}
