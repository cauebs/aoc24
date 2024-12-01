import gleam/http/request
import gleam/httpc
import gleam/int
import gleam/string
import question.{question}
import simplifile

const year: Int = 2024

const session_path: String = ".session"

const inputs_dir: String = "inputs"

fn ask_session() -> Nil {
  use session <- question(
    "Enter the value of your adventofcode.com session cookie: ",
  )
  let assert Ok(Nil) = simplifile.write(to: session_path, contents: session)
}

fn obtain_session() -> String {
  case simplifile.read(from: session_path) {
    Ok(session) -> session
    Error(_) -> {
      ask_session()
      obtain_session()
    }
  }
}

pub fn zero_padded_day(day: Int) -> String {
  int.to_string(day)
  |> string.pad_start(to: 2, with: "0")
}

fn input_path(day: Int) -> String {
  inputs_dir <> "/day" <> zero_padded_day(day) <> ".txt"
}

fn input_url(day: Int) -> String {
  "https://adventofcode.com/"
  <> int.to_string(year)
  <> "/day/"
  <> int.to_string(day)
  <> "/input"
}

fn download_input(day: Int) -> String {
  let url = input_url(day)
  let assert Ok(req) = request.to(url)

  let assert Ok(resp) =
    req
    |> request.set_cookie("session", obtain_session())
    |> httpc.send

  let input = resp.body
  let _ = simplifile.create_directory(inputs_dir)
  let assert Ok(_) = simplifile.write(input, to: input_path(day))
  input
}

pub fn obtain_input(day: Int) -> String {
  let cached =
    input_path(day)
    |> simplifile.read

  case cached {
    Ok(input) -> input
    Error(_) -> download_input(day)
  }
}
