import aoc.{obtain_input}
import day03.{parse, solve_part1, solve_part2}
import gleeunit/should

const example1 = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"

pub fn part1_example_test() {
  example1
  |> parse
  |> solve_part1
  |> should.equal(161)
}

pub fn part1_test() {
  obtain_input(3)
  |> parse
  |> solve_part1
  |> should.equal(175_700_056)
}

const example2 = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"

pub fn part2_example_test() {
  example2
  |> parse
  |> solve_part2
  |> should.equal(48)
}

pub fn part2_test() {
  obtain_input(3)
  |> parse
  |> solve_part2
  |> should.equal(71_668_682)
}
