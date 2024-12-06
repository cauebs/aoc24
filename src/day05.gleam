import aoc.{obtain_input}
import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/set.{type Set}
import gleam/string
import party

type PageNumber =
  Int

type OrderingRule =
  #(PageNumber, PageNumber)

pub type RuleSet =
  Set(OrderingRule)

type Update =
  List(PageNumber)

pub type Input {
  Input(rules: RuleSet, updates: List(Update))
}

pub fn parse(raw_input: String) -> Input {
  let number = party.digits() |> party.try(int.parse)

  let rule = {
    use left <- party.do(number)
    use _ <- party.do(party.char("|"))
    use right <- party.do(number)
    #(left, right)
    |> party.return
  }

  let update = party.sep(number, by: party.char(","))

  let assert Ok(input) =
    {
      use rules <- party.do(party.sep(rule, by: party.char("\n")))
      use _ <- party.do(party.string("\n\n"))
      use updates <- party.do(party.sep(update, by: party.char("\n")))

      Input(rules |> set.from_list, updates)
      |> party.return
    }
    |> party.go(raw_input |> string.trim_end)

  input
}

/// Part 1 -----------------------------------------------------------------------------------------
pub type Solution1 =
  Int

fn should_come_after(
  first: PageNumber,
  second: PageNumber,
  rules: RuleSet,
) -> Bool {
  rules
  |> set.contains(#(first, second))
}

fn is_correctly_ordered(update: Update, rules: RuleSet) -> Bool {
  case update {
    [] -> True
    [first, ..rest] -> {
      rest
      |> list.all(should_come_after(first, _, rules))
      && is_correctly_ordered(rest, rules)
    }
  }
}

fn get_middle_page(update: Update) -> PageNumber {
  let half = { update |> list.length } / 2
  let assert Ok(middle_page) = update |> list.drop(half) |> list.first
  middle_page
}

pub fn solve_part1(input: Input) -> Solution1 {
  input.updates
  |> list.filter(is_correctly_ordered(_, input.rules))
  |> list.map(get_middle_page)
  |> int.sum
}

/// Part 2 -----------------------------------------------------------------------------------------
pub type Solution2 =
  Solution1

fn is_incorrectly_ordered(update: Update, rules: RuleSet) -> Bool {
  is_correctly_ordered(update, rules)
  |> bool.negate
}

fn fix_update_order(update: Update, rules: RuleSet) -> Update {
  update
  |> list.sort(fn(a, b) {
    let lt = rules |> set.contains(#(a, b))
    let gt = rules |> set.contains(#(b, a))

    case lt, gt {
      True, _ -> order.Lt
      _, True -> order.Gt
      _, _ -> order.Eq
    }
  })
}

pub fn solve_part2(input: Input) -> Solution2 {
  input.updates
  |> list.filter(is_incorrectly_ordered(_, input.rules))
  |> list.map(fix_update_order(_, input.rules))
  |> list.map(get_middle_page)
  |> int.sum
}

/// Main -------------------------------------------------------------------------------------------
pub fn main() {
  let input = obtain_input(5) |> parse

  io.println("Part 1:")
  solve_part1(input) |> io.debug

  io.println("Part 2:")
  solve_part2(input) |> io.debug
}
