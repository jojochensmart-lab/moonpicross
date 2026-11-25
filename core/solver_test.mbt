///|
test "candidate enumeration and bounds" {
  assert_eq(@core.line_patterns(5, [], 100), Ok([0]))
  assert_eq(@core.line_patterns(5, [5], 100), Ok([31]))
  assert_eq(@core.line_patterns(5, [3], 100), Ok([7, 14, 28]))
  assert_eq(@core.line_patterns(10, [3, 2], 100).unwrap().length(), 15)
  assert_eq(@core.line_patterns(5, [3, 2], 100), Err(@core.Status::Invalid))
  assert_eq(@core.line_patterns(5, [-1], 100), Err(@core.Status::Invalid))
  assert_eq(@core.line_patterns(31, [], 100), Err(@core.Status::Invalid))
  assert_eq(@core.line_patterns(30, [30], 100), Ok([1073741823]))
  assert_eq(@core.line_patterns(10, [3, 2], 14), Err(@core.Status::Budget))
}

///|
test "partial search does not claim uniqueness" {
  let result = @core.solve([[1], [1]], [[1], [1]], {
    candidates: 100,
    nodes: 2,
    scans: 10000,
  })
  assert_eq(result.status, @core.Status::Budget)
  assert_true(result.first is Some(_))
  assert_eq(
    @core.solve([[1]], [[]], @core.Limits::default()).status,
    @core.Status::NoSolution,
  )
  assert_eq(
    @core.solve([[1]], [[1]], @core.Limits::default()).status,
    @core.Status::Unique,
  )
  assert_eq(
    @core.solve([[1], [1]], [[1], [1]], @core.Limits::default()).status,
    @core.Status::Multiple,
  )
  assert_eq(
    @core.solve([[0]], [[1]], @core.Limits::default()).status,
    @core.Status::Invalid,
  )
  assert_eq(
    @core.solve([[1]], [[1]], { candidates: 100, nodes: 99, scans: 0, }).status,
    @core.Status::Budget,
  )
}

///|
test "deterministic generation and successful model validation" {
  for n in [5, 10, 15] {
    let a = @core.generate(n, 7U, 45, 12, @core.Limits::default()).unwrap()
    let b = @core.generate(n, 7U, 45, 12, @core.Limits::default()).unwrap()
    assert_eq(a.grid, b.grid)
    assert_eq(a.attempts, b.attempts)
    assert_eq(a.result.status, @core.Status::Unique)
    assert_eq(a.result.first, Some(a.grid))
    assert_eq(@core.clues(a.grid, n, n), (a.rows, a.cols))
  }
  guard @core.generate(5, 1U, 45, 2, { candidates: 1, nodes: 1, scans: 1, })
    is Err(AttemptLimit) else {
    fail("expected attempt limit")
  }
}
