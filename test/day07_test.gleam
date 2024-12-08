import aoc.{obtain_input}
import day07.{parse, solve_part1, solve_part2}
import gleeunit/should

const example = "190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20"

pub fn part1_example_test() {
  example
  |> parse
  |> solve_part1
  |> should.equal(3749)
}

pub fn part1_test() {
  obtain_input(7)
  |> parse
  |> solve_part1
  |> should.equal(4_364_915_411_363)
}

pub fn part2_example_test() {
  example
  |> parse
  |> solve_part2
  |> should.equal(11_387)
}

pub fn part2_test() {
  obtain_input(7)
  |> parse
  |> solve_part2
  |> should.equal(38_322_057_216_320)
}
