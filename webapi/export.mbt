///|
fn error(message : String) -> String {
  Json::object({ "error": message.to_json() }).stringify()
}

///|
pub fn solve_puzzle(source : String) -> String {
  if source.length() > 32768 {
    return error("Puzzle file exceeds 32 KiB.")
  }
  match @core.Puzzle::from_json(source) {
    Err(e) => error(@debug.to_string(e))
    Ok(puzzle) => {
      let result = puzzle.solve(@core.Limits::default(), trace=1000).unwrap()
      Json::object({
        "puzzle": puzzle.to_json(),
        "status": @debug.to_string(result.status).to_json(),
        "first": match result.first {
          Some(grid) => grid.to_json()
          None => ([] : Array[Int32]).to_json()
        },
        "difficulty": @core.difficulty(result).to_json(),
        "steps": result.steps.to_json(),
        "trace_truncated": result.trace_truncated.to_json(),
      }).stringify()
    }
  }
}

///|
pub fn derive_puzzle(size : Int32, bits : String) -> String {
  if size < 1 || size > 15 || bits.length() != size * size {
    return error("Invalid grid dimensions.")
  }
  let cells = []
  for ch in bits {
    match ch {
      '1' => cells.push(@core.Cell::Black)
      '0' => cells.push(@core.Cell::White)
      _ => return error("Expected binary cells.")
    }
  }
  match @core.Puzzle::from_grid({ height: size, width: size, cells, }) {
    Ok(puzzle) => puzzle.to_json().stringify()
    Err(e) => error(@debug.to_string(e))
  }
}

///|
pub fn generate_puzzle(size : Int32, seed : UInt32, target : String) -> String {
  if size < 5 || size > 15 {
    return error("Select a size from 5 to 15.")
  }
  let level = if target == "" { None } else { Some(target) }
  let config : @core.GenerationConfig = {
    size,
    seed,
    density: 45,
    attempts: 24,
    limits: @core.Limits::default(),
    level,
  }
  match config.run() {
    Ok(g) => {
      let puzzle : @core.Puzzle = { version: 1, rows: g.rows, cols: g.cols, }
      Json::object({
        "puzzle": puzzle.to_json(),
        "attempts": g.attempts.to_json(),
        "difficulty": @core.difficulty(g.result).to_json(),
      }).stringify()
    }
    Err(e) => error(@debug.to_string(e))
  }
}
