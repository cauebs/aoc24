import aoc.{obtain_input}
import day$xx.{parse, solve_part1, solve_part2}
import gleeunit/should

pub fn part1_example_test() {
  "example"
  |> parse
  |> solve_part1
  |> should.equal(todo as "Example result for part 1 not set")
}

pub fn part1_test() {
  obtain_input($x)
  |> parse
  |> solve_part1
  |> should.equal(todo as "Part 1 answer not set")
}

pub fn part2_example_test() {
  "example"
  |> parse
  |> solve_part2
  |> should.equal(todo as "Example result for part 2 not set")
}

pub fn part2_test() {
  obtain_input($x)
  |> parse
  |> solve_part2
  |> should.equal(todo as "Part 2 answer not set")
}
