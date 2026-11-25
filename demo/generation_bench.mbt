///|
fn run_generation_survey() -> Unit {
  println(
    "survey,size,total,success,verified,attempts,mean_nodes,mean_ms,budget_attempts",
  )
  for n in [5, 10, 15, 20] {
    let count = if n == 20 { 100 } else { 200 }
    let mut success = 0
    let mut verified = 0
    let mut budgets = 0
    let mut nodes = 0
    let mut trials = 0
    let mut total = 0.0
    for seed in 1..<=count {
      let config : @core.GenerationConfig = {
        size: n,
        seed: seed.reinterpret_as_uint(),
        density: 45,
        attempts: 24,
        limits: @core.Limits::default(),
        level: None,
      }
      let start = @bench.monotonic_clock_start()
      let result = @core.generate(n, config.seed, 45, 24, config.limits, observe=answer => {
        trials += 1
        nodes += answer.metrics.nodes
        if answer.status is Budget {
          budgets += 1
        }
      })
      total += @bench.monotonic_clock_end(start) / 1000.0
      if result is Ok(g) {
        success += 1
        let (rows, cols) = @core.clues(g.grid, n, n)
        let answer = @core.solve(rows, cols, config.limits)
        if config.run() is Ok(repeated) &&
          repeated.grid == g.grid &&
          repeated.attempts == g.attempts &&
          rows == g.rows &&
          cols == g.cols &&
          answer.status is Unique &&
          answer.first == Some(g.grid) {
          verified += 1
        }
      }
    }
    println(
      "survey,\{n},\{count},\{success},\{verified},\{trials},\{nodes.to_double()/trials.to_double()},\{total/count.to_double()},\{budgets}",
    )
    guard success == verified else {
      abort("Generated witness or repeatability mismatch")
    }
  }
}
