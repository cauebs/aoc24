import aoc.{obtain_input}
import day08.{parse, solve_part1, solve_part2}
import gleeunit/should

const example = "............
........0...
.....0......
.......0....
....0.......
......A.....
............
............
........A...
.........A..
............
............"

pub fn part1_example_test() {
  example
  |> parse
  |> solve_part1
  |> should.equal(14)
}

pub fn part1_test() {
  obtain_input(8)
  |> parse
  |> solve_part1
  |> should.equal(400)
}

pub fn part2_example_test() {
  example
  |> parse
  |> solve_part2
  |> should.equal(34)
}

pub fn part2_test() {
  obtain_input(8)
  |> parse
  |> solve_part2
  |> should.equal(1280)
}
