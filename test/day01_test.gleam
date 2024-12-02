import aoc.{obtain_input}
import day01.{parse, solve_part1, solve_part2}
import gleeunit/should

const example: String = "3   4
4   3
2   5
1   3
3   9
3   3"

pub fn part1_example_test() {
  example
  |> parse
  |> solve_part1
  |> should.equal(11)
}

pub fn part1_test() {
  obtain_input(1)
  |> parse
  |> solve_part1
  |> should.equal(1_879_048)
}

pub fn part2_example_test() {
  example
  |> parse
  |> solve_part2
  |> should.equal(31)
}

pub fn part2_test() {
  obtain_input(1)
  |> parse
  |> solve_part2
  |> should.equal(21_024_792)
}
