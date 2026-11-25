///|
fn main {
  let clues = [[1], [3], [5], [3], [1]]
  let puzzle : @core.Puzzle = { version: 1, rows: clues, cols: clues, }
  let answer = puzzle.solve(@core.Limits::default(), trace=16).unwrap()
  println(@debug.to_string(answer.status))
  println(@core.difficulty(answer).to_json().stringify())
  if answer.first is Some(grid) {
    for y in 0..<5 {
      println(
        grid[y * 5:y * 5 + 5]
        .to_owned()
        .map(v => if v == 1 { "#" } else { "." })
        .join(""),
      )
    }
  }
}
