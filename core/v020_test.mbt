///|
test "depth ceiling preserves incomplete status" {
  let limits = @core.Limits::default()
  let hints = [[1], [1]]
  let root = @core.solve_bounded(hints, hints, limits, max_depth=0)
  assert_eq(root.status, @core.Status::Budget)
  assert_true(root.first is None)
  assert_eq(root.metrics.nodes, 1)
  assert_eq(
    @core.solve_bounded(hints, hints, limits, max_depth=1).status,
    @core.Status::Multiple,
  )
  assert_eq(
    @core.solve_bounded(hints, hints, limits, max_depth=-1).status,
    @core.Status::Invalid,
  )
}

///|
test "full and empty maximum boards solve at depth zero" {
  let limits = @core.Limits::default()
  for value in [0, 1] {
    let hints = Array::makei(30, _ => if value == 0 { [] } else { [30] })
    let result = @core.solve_bounded(hints, hints, limits, max_depth=0)
    assert_eq(result.status, @core.Status::Unique)
    assert_eq(result.first, Some(Array::make(900, value)))
  }
}

///|
test "deterministic clue fuzz retains valid solved witnesses" {
  let mut state = 23U
  let limits = @core.Limits::default()
  for case in 0..<180 {
    let w = case % 7 + 1
    let h = case / 7 % 7 + 1
    let grid = Array::makei(h * w, _ => {
      state = state ^ (state << 13)
      state = state ^ (state >> 17)
      state = state ^ (state << 5)
      (state % 2U).reinterpret_as_int()
    })
    let (rows, cols) = @core.clues(grid, h, w)
    let result = @core.solve(rows, cols, limits)
    guard result.first is Some(witness) else {
      fail("missing feasible witness")
    }
    assert_eq(@core.clues(witness, h, w), (rows, cols))
    if result.status is Unique {
      assert_eq(witness, grid)
    }
    rows[0] = [w + 1]
    assert_eq(@core.solve(rows, cols, limits).status, @core.Status::Invalid)
  }
}

///|
test "malformed puzzle payloads are rejected" {
  for
    payload in [
      "", "[]", "{", "{\"version\":1,\"rows\":[null],\"cols\":[[]]}", "{\"version\":1,\"rows\":[[2147483648]],\"cols\":[[]]}",
    ] {
    guard @core.Puzzle::from_json(payload) is Err(_) else {
      fail("malformed payload accepted")
    }
  }
}
