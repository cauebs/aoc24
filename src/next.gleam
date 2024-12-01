import aoc
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleam/result
import gleam/string
import simplifile

fn get_next_day() -> Int {
  let assert Ok(modules) = simplifile.read_directory("src")
  let assert Ok(re) = regexp.from_string("day0?(\\d+).gleam")

  modules
  |> list.flat_map(regexp.scan(re, _))
  |> list.flat_map(fn(match) {
    use submatch <- list.map(match.submatches)
    let assert Some(raw_day) = submatch
    let assert Ok(day) = int.parse(raw_day)
    day
  })
  |> list.sort(int.compare)
  |> list.last
  |> result.map(int.add(1, _))
  |> result.unwrap(or: 1)
}

fn copy_template(from source: String, to destination: String, for day: Int) {
  let assert Ok(contents) = simplifile.read(source)
  contents
  |> string.replace("$xx", aoc.zero_padded_day(day))
  |> string.replace("$x", int.to_string(day))
  |> simplifile.write(to: destination)
}

pub fn main() {
  let day = get_next_day()

  let template_src = "templates/dayxx.gleam"
  let new_src = "src/day" <> aoc.zero_padded_day(day) <> ".gleam"
  let assert Ok(_) = copy_template(from: template_src, to: new_src, for: day)

  let template_test = "templates/dayxx_test.gleam"
  let new_test = "test/day" <> aoc.zero_padded_day(day) <> "_test.gleam"
  let assert Ok(_) = copy_template(from: template_test, to: new_test, for: day)

  io.println("Created:")
  io.println("- " <> new_src)
  io.println("- " <> new_test)
}
