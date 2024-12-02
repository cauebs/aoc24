import aoc.{obtain_input}
import day02.{parse, solve_part1, solve_part2}
import gleeunit/should

const example = "7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9"

pub fn part1_example_test() {
  example
  |> parse
  |> solve_part1
  |> should.equal(2)
}

pub fn part1_test() {
  obtain_input(2)
  |> parse
  |> solve_part1
  |> should.equal(287)
}

pub fn part2_example_test() {
  example
  |> parse
  |> solve_part2
  |> should.equal(4)
}

pub fn part2_test() {
  obtain_input(2)
  |> parse
  |> solve_part2
  |> should.equal(354)
}
