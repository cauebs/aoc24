import aoc.{obtain_input}
import day05.{parse, solve_part1, solve_part2}
import gleeunit/should

const example = "47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47"

pub fn part1_example_test() {
  example
  |> parse
  |> solve_part1
  |> should.equal(143)
}

pub fn part1_test() {
  obtain_input(5)
  |> parse
  |> solve_part1
  |> should.equal(4924)
}

pub fn part2_example_test() {
  example
  |> parse
  |> solve_part2
  |> should.equal(123)
}

pub fn part2_test() {
  obtain_input(5)
  |> parse
  |> solve_part2
  |> should.equal(6085)
}
