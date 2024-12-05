import aoc.{obtain_input}
import day04.{parse, solve_part1, solve_part2}
import gleeunit/should

const example = "MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX"

pub fn part1_example_test() {
  example
  |> parse
  |> solve_part1
  |> should.equal(18)
}

pub fn part1_test() {
  obtain_input(4)
  |> parse
  |> solve_part1
  |> should.equal(2406)
}

pub fn part2_example_test() {
  example
  |> parse
  |> solve_part2
  |> should.equal(9)
}

pub fn part2_test() {
  obtain_input(4)
  |> parse
  |> solve_part2
  |> should.equal(1807)
}
