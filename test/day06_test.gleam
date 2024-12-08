import aoc.{obtain_input}
import day06.{parse, solve_part1, solve_part2}
import gleeunit/should

const example = "....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#..."

pub fn part1_example_test() {
  example
  |> parse
  |> solve_part1
  |> should.equal(41)
}

pub fn part1_test() {
  obtain_input(6)
  |> parse
  |> solve_part1
  |> should.equal(4789)
}

pub fn part2_example_test() {
  example
  |> parse
  |> solve_part2
  |> should.equal(6)
}

pub fn part2_test() {
  obtain_input(6)
  |> parse
  |> solve_part2
  |> should.equal(1304)
}
