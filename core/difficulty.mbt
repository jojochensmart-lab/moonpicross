///|
pub(all) struct DifficultyReport {
  level : String
  candidates : Int32
  largest : Int32
  rounds : Int32
  nodes : Int32
  backtracks : Int32
  scans : Int32
  forced_by_round : Array[Int32]
} derive(ToJson)

///|
pub fn difficulty(result : SolveResult) -> DifficultyReport {
  let m = result.metrics
  let level = match result.status {
    Budget => "Incomplete"
    Unique =>
      if m.nodes == 1 {
        "Easy"
      } else if m.nodes <= 20 {
        "Normal"
      } else if m.nodes <= 100 {
        "Hard"
      } else {
        "Expert"
      }
    _ => "Unrated"
  }
  {
    level,
    candidates: m.patterns,
    largest: m.largest,
    rounds: m.rounds,
    nodes: m.nodes,
    backtracks: m.backtracks,
    scans: m.scans,
    forced_by_round: m.forced_by_round.copy(),
  }
}

///|
pub(all) struct GenerationConfig {
  size : Int32
  seed : UInt32
  density : Int32
  attempts : Int32
  limits : Limits
  level : String?
}

///|
pub fn GenerationConfig::run(
  self : GenerationConfig,
) -> Result[Generated, GenerationError] {
  generate(
    self.size,
    self.seed,
    self.density,
    self.attempts,
    self.limits,
    target=self.level,
  )
}
