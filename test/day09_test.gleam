import aoc.{obtain_input}
import day09.{parse, solve_part1, solve_part2}
import gleam/erlang/atom
import gleeunit/should

const example = "2333133121414131402"

pub fn part1_example_test() {
  example
  |> parse
  |> solve_part1
  |> should.equal(1928)
}

pub fn part1_test_() {
  let timeout = atom.create_from_string("timeout")
  #(timeout, 10.0, [
    fn() {
      obtain_input(9)
      |> parse
      |> solve_part1
      |> should.equal(6_332_189_866_718)
    },
  ])
}

pub fn part2_example_test() {
  example
  |> parse
  |> solve_part2
  |> should.equal(2858)
}

pub fn part2_test() {
  obtain_input(9)
  |> parse
  |> solve_part2
  |> should.equal(6_353_648_390_778)
}
