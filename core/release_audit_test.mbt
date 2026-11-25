///|
test "invalid clues take precedence over candidate exhaustion" {
  let limits : @core.Limits = { candidates: 0, nodes: 0, scans: 0, }
  assert_eq(
    @core.solve([[1], [3]], [[1], [1]], limits).status,
    @core.Status::Invalid,
  )
  assert_eq(
    @core.solve([[1], [1]], [[1], [1]], limits).status,
    @core.Status::Budget,
  )
}

///|
test "negative generator budgets are invalid options" {
  let limits : @core.Limits = { candidates: 10, nodes: -1, scans: 100, }
  guard @core.generate(5, 7U, 45, 24, limits) is Err(InvalidOptions) else {
    fail("negative solver budget must be rejected before generation")
  }
}

///|
test "reflection and transpose preserve proofs and tied branch determinism" {
  let row = [[1], [2], [1], [1]]
  let col = [[2], [1, 1], [1]]
  let limits = @core.Limits::default()
  let original = @core.solve(row, col, limits)
  let rotated = @core.solve(col.rev(), row.map(line => line.rev()), limits)
  assert_eq(original.status, rotated.status)
  let hints = Array::makei(20, _ => [1])
  let first = @core.solve_bounded(hints, hints, limits)
  assert_eq(first.status, @core.Status::Multiple)
  let repeat = @core.solve_bounded(hints, hints, limits)
  assert_eq(first.first, repeat.first)
  assert_eq(first.metrics.scans, repeat.metrics.scans)
  let limited = @core.solve_bounded(hints, hints, limits, max_depth=1)
  assert_eq(limited.status, @core.Status::Budget)
}

///|
test "random invalid clues and exhausted generation attempts" {
  let limits = @core.Limits::default()
  let mut state = 101U
  for i in 0..<160 {
    state = state ^ (state << 13)
    state = state ^ (state >> 17)
    state = state ^ (state << 5)
    let width = i % 30 + 1
    let bad = width + (state % 100U).reinterpret_as_int() + 1
    let cols = Array::makei(width, _ => [1])
    assert_eq(@core.solve([[bad]], cols, limits).status, @core.Status::Invalid)
    let payload = "{\"version\":1,\"rows\":[[\{bad}]],\"cols\":["
    assert_true(@core.Puzzle::from_json(payload) is Err(InvalidFormat))
  }
  let zero : @core.Limits = { candidates: 0, nodes: 0, scans: 0, }
  let seen = [0]
  let result = @core.generate(20, 175U, 45, 24, zero, observe=answer => {
    assert_eq(answer.status, @core.Status::Budget) catch {
      _ => abort("Expected Budget")
    }
    seen[0] += 1
  })
  assert_true(result is Err(AttemptLimit))
  assert_eq(seen[0], 24)
}
