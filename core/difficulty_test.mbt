///|
test "difficulty distinguishes budget and certifies filtered generation" {
  let easy = @core.solve([[1]], [[1]], @core.Limits::default())
  assert_eq(@core.difficulty(easy).level, "Easy")
  let uncertain = @core.solve([[1]], [[1]], {
    candidates: 100,
    nodes: 0,
    scans: 100,
  })
  assert_eq(@core.difficulty(uncertain).level, "Incomplete")
  let cfg : @core.GenerationConfig = {
    size: 5,
    seed: 7U,
    density: 45,
    attempts: 12,
    limits: @core.Limits::default(),
    level: Some("Easy"),
  }
  let attempt = cfg.run().unwrap()
  assert_eq(@core.difficulty(attempt.result).level, "Easy")
  assert_true(
    @core.generate(
      5,
      7U,
      45,
      1,
      @core.Limits::default(),
      target=Some("Impossible"),
    )
    is Err(InvalidOptions),
  )
}
