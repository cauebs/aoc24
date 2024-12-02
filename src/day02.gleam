import aoc.{obtain_input}
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import party

type Level =
  Int

type Report =
  List(Level)

pub type Input =
  List(Report)

pub fn parse(raw_input: String) -> Input {
  let level_parser = party.digits() |> party.try(int.parse)
  let report_parser = party.sep(level_parser, by: party.char(" "))
  let input_parser = party.sep(report_parser, by: party.char("\n"))
  let assert Ok(input) = party.go(input_parser, string.trim_end(raw_input))
  input
}

/// Part 1 -----------------------------------------------------------------------------------------
pub type Solution1 =
  Int

fn is_safe(report: Report) -> Bool {
  let pairs = list.window_by_2(report)

  let within_tolerance = fn(pair: #(Level, Level)) {
    let delta = int.absolute_value(pair.0 - pair.1)
    delta >= 1 && delta <= 3
  }

  list.all(pairs, fn(pair) { within_tolerance(pair) && pair.0 <= pair.1 })
  || list.all(pairs, fn(pair) { within_tolerance(pair) && pair.0 >= pair.1 })
}

pub fn solve_part1(input: Input) -> Solution1 {
  input
  |> list.count(is_safe)
}

/// Part 2 -----------------------------------------------------------------------------------------
pub type Solution2 =
  Solution1

fn remove_index(l: List(a), index: Int) -> List(a) {
  let before = list.take(l, up_to: index)
  let after = list.drop(l, up_to: index + 1)
  list.append(before, after)
}

fn is_safe_with_dampener(report: Report) -> Bool {
  report
  |> list.index_map(fn(_, i) { report |> remove_index(i) })
  |> list.any(is_safe)
}

pub fn solve_part2(input: Input) -> Solution2 {
  input
  |> list.count(is_safe_with_dampener)
}

/// Main -------------------------------------------------------------------------------------------
pub fn main() {
  let input = obtain_input(2) |> parse

  io.println("Part 1:")
  solve_part1(input) |> io.debug

  io.println("Part 2:")
  solve_part2(input) |> io.debug
}
