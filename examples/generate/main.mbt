///|
fn main {
  let request : @core.GenerationConfig = {
    size: 10,
    seed: 7U,
    density: 45,
    attempts: 24,
    limits: @core.Limits::default(),
    level: None,
  }
  let generated = request.run().unwrap()
  let puzzle : @core.Puzzle = {
    version: 1,
    rows: generated.rows,
    cols: generated.cols,
  }
  let verified = puzzle.solve(@core.Limits::default()).unwrap()
  guard verified.status is Unique else {
    abort("Generation failed verification")
  }
  println(puzzle.to_json().stringify())
}
