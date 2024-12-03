import aoc.{obtain_input}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regexp

pub type Instruction {
  Do
  Dont
  Mul(Int, Int)
}

pub type Input =
  List(Instruction)

pub fn parse(raw_input: String) -> Input {
  let assert Ok(instruction_re) =
    regexp.from_string("mul\\((\\d+),(\\d+)\\)|do\\(\\)|don't\\(\\)")

  regexp.scan(instruction_re, raw_input)
  |> list.map(fn(match) {
    case match.content, match.submatches {
      "do()", [] -> Do
      "don't()", [] -> Dont
      _, [Some(l), Some(r)] -> {
        let assert Ok(lhs) = int.parse(l)
        let assert Ok(rhs) = int.parse(r)
        Mul(lhs, rhs)
      }
      _, _ -> panic
    }
  })
}

/// Part 1 -----------------------------------------------------------------------------------------
pub type Solution1 =
  Int

pub fn solve_part1(input: Input) -> Solution1 {
  input
  |> list.filter_map(fn(instruction) {
    case instruction {
      Mul(lhs, rhs) -> Ok(lhs * rhs)
      _ -> Error(Nil)
    }
  })
  |> int.sum
}

/// Part 2 -----------------------------------------------------------------------------------------
pub type Solution2 =
  Solution1

fn run(instructions: List(Instruction), enabled: Bool, total: Int) -> Int {
  case instructions {
    [] -> total
    [instruction, ..rest] ->
      case enabled, instruction {
        True, Mul(lhs, rhs) -> run(rest, True, total + rhs * lhs)
        False, Do -> run(rest, True, total)
        True, Dont -> run(rest, False, total)
        _, _ -> run(rest, enabled, total)
      }
  }
}

pub fn solve_part2(input: Input) -> Solution2 {
  let enabled = True
  let starting_total = 0
  input |> run(enabled, starting_total)
}

/// Main -------------------------------------------------------------------------------------------
pub fn main() {
  let input = obtain_input(3) |> parse

  io.println("Part 1:")
  solve_part1(input) |> io.debug

  io.println("Part 2:")
  solve_part2(input) |> io.debug
}
