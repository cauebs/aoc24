import aoc.{obtain_input}
import gleam/bool
import gleam/dict.{type Dict}
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/otp/task
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import gleam/string

type Position =
  #(Int, Int)

pub type Cell {
  Blank
  Guard
  Obstacle
}

pub type Input {
  Input(map_rows: Int, map_columns: Int, cells: List(#(Position, Cell)))
}

pub fn parse(raw_input: String) -> Input {
  let lines =
    raw_input
    |> string.trim_end
    |> string.split("\n")

  let cells =
    lines
    |> list.index_map(fn(line, row_index) {
      line
      |> string.to_graphemes
      |> list.index_map(fn(character, column_index) {
        let cell = case character {
          "." -> Blank
          "^" -> Guard
          "#" -> Obstacle
          _ -> panic as "unexpected symbol in input"
        }

        #(#(row_index, column_index), cell)
      })
    })
    |> list.flatten

  let map_rows = lines |> list.length
  let assert Ok(map_columns) = lines |> list.first |> result.map(string.length)

  Input(map_rows, map_columns, cells)
}

/// Part 1 -----------------------------------------------------------------------------------------
pub type Solution1 =
  Int

fn find_guard_start(cells: List(#(Position, Cell))) -> Position {
  let assert Ok(guard_start) =
    cells
    |> list.find(fn(cell) { cell.1 == Guard })
    |> result.map(pair.first)
  guard_start
}

fn obstacle_positions(cells: List(#(Position, Cell))) -> List(Position) {
  cells
  |> list.filter(fn(cell) { cell.1 == Obstacle })
  |> list.map(pair.first)
}

type Direction {
  Up
  Down
  Left
  Right
}

fn next_direction(direction: Direction) -> Direction {
  case direction {
    Up -> Right
    Right -> Down
    Down -> Left
    Left -> Up
  }
}

fn move_once(current: Position, direction: Direction) -> Position {
  case direction {
    Up -> #(current.0 - 1, current.1)
    Down -> #(current.0 + 1, current.1)
    Left -> #(current.0, current.1 - 1)
    Right -> #(current.0, current.1 + 1)
  }
}

fn in_bounds(position: Position, map_rows: Int, map_columns: Int) -> Bool {
  position.0 >= 0
  && position.0 < map_rows
  && position.1 >= 0
  && position.1 < map_columns
}

fn patrol_path(
  current: Position,
  direction: Direction,
  map_rows: Int,
  map_columns: Int,
  obstacles: Set(Position),
) -> List(Position) {
  let next_position = current |> move_once(direction)

  let out_of_bounds =
    next_position |> in_bounds(map_rows, map_columns) |> bool.negate
  use <- bool.guard(out_of_bounds, return: [current])

  case obstacles |> set.contains(next_position) {
    True -> {
      let new_direction = direction |> next_direction
      patrol_path(current, new_direction, map_rows, map_columns, obstacles)
    }

    False -> [
      current,
      ..patrol_path(next_position, direction, map_rows, map_columns, obstacles)
    ]
  }
}

pub fn solve_part1(input: Input) -> Solution1 {
  let guard_start = find_guard_start(input.cells)
  let obstacles = obstacle_positions(input.cells) |> set.from_list

  patrol_path(guard_start, Up, input.map_rows, input.map_columns, obstacles)
  |> set.from_list
  |> set.size
}

/// Part 2 -----------------------------------------------------------------------------------------
pub type Solution2 =
  Solution1

type Axis {
  Horizontal
  Vertical
}

fn into_axis(direction: Direction) -> Axis {
  case direction {
    Up | Down -> Vertical
    Left | Right -> Horizontal
  }
}

type ObstacleIndex {
  ObstacleIndex(per_row: Dict(Int, List(Int)), per_column: Dict(Int, List(Int)))
}

fn obstacles_in_direction(
  obstacles: List(Position),
  axis: Axis,
) -> Dict(Int, List(Int)) {
  let #(get_primary, get_secondary) = case axis {
    Horizontal -> #(pair.first, pair.second)
    Vertical -> #(pair.second, pair.first)
  }

  obstacles
  |> list.group(get_primary)
  |> dict.map_values(fn(_, positions) {
    positions |> list.map(get_secondary) |> list.sort(int.compare)
  })
}

fn make_obstacle_index(obstacles: List(Position)) -> ObstacleIndex {
  let per_row = obstacles |> obstacles_in_direction(Horizontal)
  let per_column = obstacles |> obstacles_in_direction(Vertical)
  ObstacleIndex(per_row, per_column)
}

type Sign {
  Positive
  Negative
}

fn sign(direction: Direction) -> Sign {
  case direction {
    Up | Left -> Negative
    Down | Right -> Positive
  }
}

fn find_next_obstacle(
  position: Position,
  direction: Direction,
  obstacle_index: ObstacleIndex,
) -> Result(Position, Nil) {
  let axis = direction |> into_axis

  let #(axis_index, index_along_axis) = case axis {
    Horizontal -> #(position.0, position.1)
    Vertical -> #(position.1, position.0)
  }

  let axis_obstacles =
    case axis {
      Horizontal -> obstacle_index.per_row
      Vertical -> obstacle_index.per_column
    }
    |> dict.get(axis_index)
    |> result.unwrap(or: [])
    |> list.sort(int.compare)

  let direction_sign = direction |> sign

  case direction_sign {
    Positive ->
      axis_obstacles
      |> list.filter(fn(obstacle_index) { obstacle_index > index_along_axis })
      |> list.first
    Negative ->
      axis_obstacles
      |> list.filter(fn(obstacle_index) { obstacle_index < index_along_axis })
      |> list.last
  }
  |> result.map(fn(obstacle_index) {
    case axis {
      Horizontal -> #(axis_index, obstacle_index)
      Vertical -> #(obstacle_index, axis_index)
    }
  })
}

fn opposite(direction: Direction) -> Direction {
  case direction {
    Up -> Down
    Down -> Up
    Left -> Right
    Right -> Left
  }
}

fn patrol_path_loops_aux(
  current: Position,
  direction: Direction,
  obstacle_index: ObstacleIndex,
  obstacle_hits: Set(#(Position, Direction)),
) -> Bool {
  case find_next_obstacle(current, direction, obstacle_index) {
    Error(_) -> False
    Ok(obstacle) -> {
      let hit = #(obstacle, direction)
      case obstacle_hits |> set.contains(hit) {
        True -> True
        False -> {
          let new_position = obstacle |> move_once(direction |> opposite)
          let new_direction = direction |> next_direction
          patrol_path_loops_aux(
            new_position,
            new_direction,
            obstacle_index,
            obstacle_hits |> set.insert(hit),
          )
        }
      }
    }
  }
}

fn patrol_path_loops(
  start: Position,
  direction: Direction,
  obstacle_index: ObstacleIndex,
) -> Bool {
  patrol_path_loops_aux(start, direction, obstacle_index, set.new())
}

fn async_map(list: List(a), func: fn(a) -> b) -> List(b) {
  let async_func = fn(item) { task.async(fn() { func(item) }) }
  list |> list.map(async_func) |> list.map(task.await_forever)
}

pub fn solve_part2(input: Input) -> Solution2 {
  let guard_start = find_guard_start(input.cells)
  let obstacles = obstacle_positions(input.cells)

  let blank_positions =
    input.cells
    |> list.filter(fn(cell) { cell.1 == Blank })
    |> list.map(pair.first)

  blank_positions
  |> async_map(fn(potential_obstacle_position) {
    // |> list.map(fn(potential_obstacle_position) {
    let obstacles = [potential_obstacle_position, ..obstacles]
    let obstacle_index = make_obstacle_index(obstacles)
    patrol_path_loops(guard_start, Up, obstacle_index)
  })
  |> list.count(function.identity)
}

/// Main -------------------------------------------------------------------------------------------
pub fn main() {
  let input = obtain_input(6) |> parse

  io.println("Part 1:")
  solve_part1(input) |> io.debug

  io.println("Part 2:")
  solve_part2(input) |> io.debug
}
