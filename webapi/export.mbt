///|
pub fn solve_demo() -> String {
  let clue = [[1], [3], [5], [3], [1]]
  let answer = @core.solve(clue, clue, @core.Limits::default())
  match (answer.status, answer.first) {
    (Unique, Some(grid)) => "Unique:" + grid.map(v => v.to_string()).join("")
    _ => "Unverified"
  }
}
