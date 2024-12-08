import aoc.{obtain_input}
import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/pair
import gleam/result
import gleam/set
import gleam/string
import gleam/yielder.{type Yielder}

type Position =
  #(Int, Int)

type Frequency =
  String

pub type Input {
  Input(map_rows: Int, map_columns: Int, antennas: List(#(Position, Frequency)))
}

pub fn parse(raw_input: String) -> Input {
  let lines =
    raw_input
    |> string.trim
    |> string.split("\n")

  let map_rows = lines |> list.length
  let assert Ok(map_columns) =
    lines |> list.first() |> result.map(string.length)

  let antennas =
    lines
    |> list.index_map(fn(line, row_index) {
      line
      |> string.to_graphemes
      |> list.index_map(fn(char, column_index) {
        #(#(row_index, column_index), char)
      })
    })
    |> list.flatten
    |> list.filter_map(fn(pair) {
      case pair.1 {
        "." -> Error(Nil)
        frequency -> Ok(#(pair.0, frequency))
      }
    })

  Input(map_rows, map_columns, antennas)
}

/// Part 1 -----------------------------------------------------------------------------------------
pub type Solution1 =
  Int

fn get_antinode(source: Position, target: Position) -> Position {
  let row_delta = target.0 - source.0
  let col_delta = target.1 - source.1
  #(target.0 + row_delta, target.1 + col_delta)
}

fn find_antinodes(antenna_positions: List(Position)) -> List(Position) {
  antenna_positions
  |> list.combination_pairs
  |> list.flat_map(fn(pair) {
    [get_antinode(pair.0, pair.1), get_antinode(pair.1, pair.0)]
  })
}

fn is_within_bounds(position: Position, map_rows: Int, map_columns: Int) -> Bool {
  position.0 >= 0
  && position.0 < map_rows
  && position.1 >= 0
  && position.1 < map_columns
}

fn frequency_groups(
  antennas: List(#(Position, Frequency)),
) -> List(List(Position)) {
  let get_position = pair.first
  let get_frequency = pair.second

  let grouped_by_frequency: Dict(Frequency, List(#(Position, Frequency))) =
    list.group(antennas, by: get_frequency)

  use group <- list.map(grouped_by_frequency |> dict.values)
  group |> list.map(get_position)
}

pub fn solve_part1(input: Input) -> Solution1 {
  frequency_groups(input.antennas)
  |> list.flat_map(find_antinodes)
  |> set.from_list
  |> set.filter(is_within_bounds(_, input.map_rows, input.map_columns))
  |> set.size
}

/// Part 2 -----------------------------------------------------------------------------------------
pub type Solution2 =
  Solution1

fn get_harmonics_antinodes(
  source: Position,
  target: Position,
) -> Yielder(Position) {
  let row_delta = target.0 - source.0
  let col_delta = target.1 - source.1

  yielder.iterate(from: target, with: fn(pos) {
    #(pos.0 + row_delta, pos.1 + col_delta)
  })
}

fn find_harmonics_antinodes(
  antenna_positions: List(Position),
  map_rows: Int,
  map_columns: Int,
) -> List(Position) {
  use pair <- list.flat_map(antenna_positions |> list.combination_pairs)

  use antinodes <- list.flat_map([
    get_harmonics_antinodes(pair.0, pair.1),
    get_harmonics_antinodes(pair.1, pair.0),
  ])

  antinodes
  |> yielder.take_while(is_within_bounds(_, map_rows, map_columns))
  |> yielder.to_list
}

pub fn solve_part2(input: Input) -> Solution2 {
  frequency_groups(input.antennas)
  |> list.flat_map(find_harmonics_antinodes(
    _,
    input.map_rows,
    input.map_columns,
  ))
  |> set.from_list
  |> set.filter(is_within_bounds(_, input.map_rows, input.map_columns))
  |> set.size
}

/// Main -------------------------------------------------------------------------------------------
pub fn main() {
  let input = obtain_input(8) |> parse

  io.println("Part 1:")
  solve_part1(input) |> io.debug

  io.println("Part 2:")
  solve_part2(input) |> io.debug
}
