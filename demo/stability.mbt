///|
fn run_stability() -> Unit {
  println(
    "stability,group,size,seed,outcome,attempts,budget,multiple,nodes,ms,grid",
  )
  for recent in [false, true] {
    for n in [5, 10, 15, 20] {
      let count = if n == 20 && !recent { 100 } else { 200 }
      for offset in 1..<=count {
        let seed = if recent { 10000 + offset } else { offset }
        let group = if recent { "new" } else { "original" }
        let limits = @core.Limits::default()
        let mut attempts = 0
        let mut budget = 0
        let mut multi = 0
        let mut nodes = 0
        let start = @bench.monotonic_clock_start()
        let result = @core.generate(
          n,
          seed.reinterpret_as_uint(),
          45,
          24,
          limits,
          observe=answer => {
            attempts += 1
            nodes += answer.metrics.nodes
            match answer.status {
              Budget => budget += 1
              Multiple => multi += 1
              _ => ()
            }
          },
        )
        let ms = @bench.monotonic_clock_end(start) / 1000.0
        match result {
          Ok(g) => {
            let replay = @core.generate(
              n,
              seed.reinterpret_as_uint(),
              45,
              24,
              limits,
            ).unwrap()
            let (rows, cols) = @core.clues(g.grid, n, n)
            let check = @core.solve(rows, cols, limits)
            guard replay.grid == g.grid &&
              replay.attempts == attempts &&
              g.rows == rows &&
              g.cols == cols &&
              check.status is Unique &&
              check.first == Some(g.grid) else {
              abort("Witness or seed replay mismatch")
            }
            let bits = g.grid.map(bit => bit.to_string()).join("")
            println(
              "stability,\{group},\{n},\{seed},Unique,\{attempts},\{budget},\{multi},\{nodes},\{ms},\{bits}",
            )
          }
          Err(AttemptLimit) => {
            guard attempts == 24 && budget + multi == attempts else {
              abort("Unexpected exhausted result")
            }
            println(
              "stability,\{group},\{n},\{seed},AttemptLimit,\{attempts},\{budget},\{multi},\{nodes},\{ms},",
            )
          }
          Err(_) => abort("Unexpected generation error")
        }
      }
    }
  }
}
