import aoc.{obtain_input}
import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/string

type Position =
  #(Int, Int)

type Letter =
  String

type Grid =
  Dict(Position, Letter)

pub type Input =
  Grid

pub fn parse(raw_input: String) -> Input {
  {
    let lines = raw_input |> string.trim |> string.split("\n")
    use line, row_index <- list.index_map(lines)

    let letters_in_line = line |> string.to_graphemes()
    use letter, column_index <- list.index_map(letters_in_line)

    #(#(row_index, column_index), letter)
  }
  |> list.flatten
  |> dict.from_list
}

/// Part 1 -----------------------------------------------------------------------------------------
pub type Solution1 =
  Int

type Direction =
  Position

fn directions() -> List(Direction) {
  use delta_row <- list.flat_map([-1, 0, 1])
  use delta_col <- list.filter_map([-1, 0, 1])

  case delta_row, delta_col {
    0, 0 -> Error(Nil)
    _, _ -> Ok(#(delta_row, delta_col))
  }
}

fn move(from start: Position, towards dir: Direction) -> Position {
  #(start.0 + dir.0, start.1 + dir.1)
}

fn match_letters(
  grid: Grid,
  start: Position,
  direction: Direction,
  letters: List(String),
) -> Bool {
  case grid |> dict.get(start), letters {
    _, [] -> True

    Ok(letter), [expected, ..rest] if letter == expected ->
      match_letters(grid, start |> move(direction), direction, rest)

    _, _ -> False
  }
}

fn count_word_occurrences(grid: Grid, word: String) -> Int {
  let assert [first_letter, ..other_letters] = word |> string.to_graphemes

  let positions_matching_first_letter =
    grid
    |> dict.filter(fn(_pos, letter) { letter == first_letter })
    |> dict.keys

  positions_matching_first_letter
  |> list.flat_map(fn(pos) {
    use direction <- list.map(directions())
    #(pos |> move(direction), direction)
  })
  |> list.count(fn(start_and_direction) {
    let #(start, direction) = start_and_direction
    match_letters(grid, start, direction, other_letters)
  })
}

pub fn solve_part1(input: Input) -> Solution1 {
  input
  |> count_word_occurrences("XMAS")
}

/// Part 2 -----------------------------------------------------------------------------------------
pub type Solution2 =
  Solution1

fn diagonals() -> List(Direction) {
  use delta_row <- list.flat_map([-1, 1])
  use delta_col <- list.filter_map([-1, 1])

  case delta_row, delta_col {
    0, 0 -> Error(Nil)
    _, _ -> Ok(#(delta_row, delta_col))
  }
}

fn is_x_mas(grid: Grid, center: Position) -> Bool {
  case
    diagonals()
    |> list.map(move(from: center, towards: _))
    |> list.filter_map(dict.get(grid, _))
  {
    ["M", "S", "M", "S"] -> True
    ["S", "M", "S", "M"] -> True
    ["M", "M", "S", "S"] -> True
    ["S", "S", "M", "M"] -> True
    _ -> False
  }
}

fn count_x_mas(grid: Grid) -> Int {
  grid
  |> dict.filter(fn(_pos, letter) { letter == "A" })
  |> dict.keys
  |> list.count(is_x_mas(grid, _))
}

pub fn solve_part2(input: Input) -> Solution2 {
  input
  |> count_x_mas
}

/// Main -------------------------------------------------------------------------------------------
pub fn main() {
  let input = obtain_input(4) |> parse

  io.println("Part 1:")
  solve_part1(input) |> io.debug

  io.println("Part 2:")
  solve_part2(input) |> io.debug
}
