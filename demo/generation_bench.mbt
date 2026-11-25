///|
fn run_generation_survey() -> Unit {
  println(
    "survey,size,n,success,validated,failures,budget_attempts,average_ms,max_ms,mean_nodes_per_attempt",
  )
  for n in [5, 10, 15] {
    let mut success = 0
    let mut verified = 0
    let mut budgets = 0
    let mut nodes = 0
    let mut trials = 0
    let mut total = 0.0
    let mut longest = 0.0
    for seed in 1..<=100 {
      let start = @bench.monotonic_clock_start()
      let result = @core.generate(
        n,
        seed.to_uint(),
        45,
        24,
        @core.Limits::default(),
        observe=answer => {
          trials += 1
          nodes += answer.metrics.nodes
          if answer.status is Budget {
            budgets += 1
          }
        },
      )
      let ms = @bench.monotonic_clock_end(start) / 1000.0
      total += ms
      if ms > longest {
        longest = ms
      }
      if result is Ok(g) {
        success += 1
        let (rows, cols) = @core.clues(g.grid, n, n)
        let answer = @core.solve(rows, cols, @core.Limits::default())
        if rows == g.rows &&
          cols == g.cols &&
          answer.status is Unique &&
          answer.first == Some(g.grid) {
          verified += 1
        }
      }
    }
    println(
      "survey,\{n},100,\{success},\{verified},\{100 - success},\{budgets},\{total / 100.0},\{longest},\{nodes.to_double() / trials.to_double()}",
    )
  }
}
