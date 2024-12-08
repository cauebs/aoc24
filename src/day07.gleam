import aoc.{obtain_input}
import gleam/int
import gleam/io
import gleam/list
import gleam/otp/task
import party

pub type Equation {
  Equation(test_value: Int, numbers: List(Int))
}

pub type Input =
  List(Equation)

pub fn parse(raw_input: String) -> Input {
  let number = party.digits() |> party.try(int.parse)

  let equation = {
    use test_value <- party.do(number)
    use _ <- party.do(party.string(": "))
    use numbers <- party.do(number |> party.sep(by: party.char(" ")))

    party.return(Equation(test_value, numbers))
  }

  let assert Ok(input) =
    equation
    |> party.sep(by: party.char("\n"))
    |> party.go(raw_input)

  input
}

/// Part 1 -----------------------------------------------------------------------------------------
pub type Solution1 =
  Int

type Operator {
  Add
  Mul
  Concat
}

fn apply(op: Operator, lhs: Int, rhs: Int) -> Int {
  case op {
    Add -> lhs + rhs
    Mul -> lhs * rhs
    Concat -> {
      let assert Ok(result) =
        { int.to_string(lhs) <> int.to_string(rhs) }
        |> int.parse
      result
    }
  }
}

fn could_be_true_aux(
  from accum: Int,
  with numbers: List(Int),
  targeting target: Int,
  trying operators: List(Operator),
) -> Bool {
  case numbers {
    [] -> accum == target
    [number, ..rest] -> {
      operators
      |> list.map(apply(_, accum, number))
      |> list.any(fn(result) {
        could_be_true_aux(
          from: result,
          with: rest,
          targeting: target,
          trying: operators,
        )
      })
    }
  }
}

fn could_be_true(equation: Equation, possible_operators: List(Operator)) -> Bool {
  let assert [first_number, ..rest] = equation.numbers
  could_be_true_aux(
    from: first_number,
    with: rest,
    targeting: equation.test_value,
    trying: possible_operators,
  )
}

pub fn solve_part1(input: Input) -> Solution1 {
  input
  |> list.filter(could_be_true(_, [Add, Mul]))
  |> list.map(fn(equation) { equation.test_value })
  |> int.sum
}

/// Part 2 -----------------------------------------------------------------------------------------
pub type Solution2 =
  Solution1

fn async_filter(list: List(a), pred: fn(a) -> Bool) -> List(a) {
  let async_pred = fn(item) {
    task.async(fn() {
      case pred(item) {
        True -> Ok(item)
        False -> Error(Nil)
      }
    })
  }
  list
  |> list.map(async_pred)
  |> list.filter_map(task.await_forever)
}

pub fn solve_part2(input: Input) -> Solution2 {
  input
  |> async_filter(could_be_true(_, [Add, Mul, Concat]))
  |> list.map(fn(equation) { equation.test_value })
  |> int.sum
}

/// Main -------------------------------------------------------------------------------------------
pub fn main() {
  let input = obtain_input(7) |> parse

  io.println("Part 1:")
  solve_part1(input) |> io.debug

  io.println("Part 2:")
  solve_part2(input) |> io.debug
}
