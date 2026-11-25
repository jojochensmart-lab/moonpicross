///|
fn main {
  println(
    "generator: size,seed,status,attempts,patterns,largest,rounds,nodes,backtracks,scans,total_us",
  )
  for n in [5, 10, 15, 20, 30] {
    let grid = Array::makei(n * n, i => {
      if (i * i + 13 * i + 19 * (i / n) * (i / n)) % 101 < 45 {
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
      "solve,\{n},\{@debug.to_string(answer.status)},\{m.patterns},\{m.largest},\{m.rounds},\{m.nodes},\{m.backtracks},\{m.scans},\{elapsed}",
    )
    for seed in [1U, 7U, 99U] {
      let start = @bench.monotonic_clock_start()
      let generated = @core.generate(n, seed, 45, 12, @core.Limits::default())
      let elapsed = @bench.monotonic_clock_end(start)
      match generated {
        Ok(puzzle) => {
          let m = puzzle.result.metrics
          println(
            "\{n},\{seed},unique,\{puzzle.attempts},\{m.patterns},\{m.largest},\{m.rounds},\{m.nodes},\{m.backtracks},\{m.scans},\{elapsed}",
          )
        }
        Err(e) => println("\{n},\{seed},\{@debug.to_string(e)},\{elapsed}")
      }
    }
  }
  run_generation_survey()
}
