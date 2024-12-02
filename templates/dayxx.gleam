import aoc.{obtain_input}
import gleam/io

pub type Input

pub fn parse(raw_input: String) -> Input {
  todo as "Input parsing not implemented"
}

/// Part 1 -----------------------------------------------------------------------------------------
pub type Solution1 =
  Int

pub fn solve_part1(input: Input) -> Solution1 {
  todo as "Solution for part 1 not implemented"
}

/// Part 2 -----------------------------------------------------------------------------------------
pub type Solution2 =
  Solution1

pub fn solve_part2(input: Input) -> Solution2 {
  todo as "Solution for part 2 not implemented"
}

/// Main -------------------------------------------------------------------------------------------
pub fn main() {
  let input = obtain_input($x) |> parse

  io.println("Part 1:")
  solve_part1(input) |> io.debug

  io.println("Part 2:")
  solve_part2(input) |> io.debug
}
