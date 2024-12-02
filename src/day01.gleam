import aoc.{obtain_input}
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import party.{type Parser, do}

type LocationId =
  Int

pub type Input =
  #(List(LocationId), List(LocationId))

pub fn parse(raw_input: String) -> Input {
  let number = fn() -> Parser(Int, Nil) {
    party.digits()
    |> party.try(int.parse)
  }

  let line = fn() -> Parser(#(LocationId, LocationId), Nil) {
    use first <- do(number())
    use _ <- do(party.whitespace())
    use second <- do(number())

    #(first, second)
    |> party.return
  }

  let parser = party.sep(line(), by: party.char("\n"))
  let assert Ok(input) = party.go(parser, raw_input)
  list.unzip(input)
}

/// Part 1 -----------------------------------------------------------------------------------------
pub type Solution1 =
  Int

fn map_both(pair: #(a, a), func: fn(a) -> b) -> #(b, b) {
  pair
  |> pair.map_first(func)
  |> pair.map_second(func)
}

fn zip_pair(pair: #(List(a), List(b))) -> List(#(a, b)) {
  list.zip(pair.0, pair.1)
}

fn pairwise_map(pairs: List(#(a, b)), func: fn(a, b) -> c) -> List(c) {
  use #(first, second) <- list.map(pairs)
  func(first, second)
}

pub fn solve_part1(input: Input) -> Solution1 {
  input
  |> map_both(list.sort(_, by: int.compare))
  |> zip_pair
  |> pairwise_map(int.subtract)
  |> list.map(int.absolute_value)
  |> int.sum
}

/// Part 2 -----------------------------------------------------------------------------------------
pub type Solution2 =
  Solution1

pub fn solve_part2(input: Input) -> Solution2 {
  let #(left, right) = input

  let scores = {
    use number <- list.map(left)
    let count = list.count(right, fn(n) { n == number })
    number * count
  }

  int.sum(scores)
}

/// Main
pub fn main() {
  let input = obtain_input(1) |> parse

  io.println("Part 1:")
  solve_part1(input) |> io.debug

  io.println("Part 2:")
  solve_part2(input) |> io.debug
}
