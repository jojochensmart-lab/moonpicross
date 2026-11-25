///|
fn main {
  println("solve,size,case,status,nodes,backtracks,scans,us")
  for n in [5, 10, 15, 20] {
    for seed in 0..<60 {
      let mut state = (seed + 1).reinterpret_as_uint()
      let grid = Array::makei(n * n, _ => {
        state = state ^ (state << 13)
        state = state ^ (state >> 17)
        state = state ^ (state << 5)
        if state % 100U < 45U {
          1
        } else {
          0
        }
      })
      let (rows, cols) = @core.clues(grid, n, n)
      let start = @bench.monotonic_clock_start()
      let answer = @core.solve(rows, cols, @core.Limits::default())
      let elapsed = @bench.monotonic_clock_end(start)
      let m = answer.metrics
      println(
        "solve,\{n},\{seed},\{@debug.to_string(answer.status)},\{m.nodes},\{m.backtracks},\{m.scans},\{elapsed}",
      )
    }
  }
  run_generation_survey()
}
