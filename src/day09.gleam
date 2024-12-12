import aoc.{obtain_input}
import gleam/bool
import gleam/deque.{type Deque}
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/string

type FileId =
  Int

pub type Block {
  FileBlock(FileId)
  FreeBlock
}

pub type Input =
  List(Block)

fn read_starting_with_file_block(
  digits: List(Int),
  current_id: Int,
) -> List(Block) {
  case digits {
    [] -> []
    [first, ..rest] ->
      list.repeat(FileBlock(current_id), times: first)
      |> list.append(read_starting_with_free_space(rest, current_id))
  }
}

fn read_starting_with_free_space(
  digits: List(Int),
  current_id: Int,
) -> List(Block) {
  case digits {
    [] -> []
    [first, ..rest] ->
      list.repeat(FreeBlock, times: first)
      |> list.append(read_starting_with_file_block(rest, current_id + 1))
  }
}

fn disk_map_from_dense_format(digits: List(Int)) -> List(Block) {
  digits |> read_starting_with_file_block(0)
}

pub fn parse(raw_input: String) -> Input {
  let assert Ok(digits) =
    raw_input
    |> string.trim_end
    |> string.to_graphemes
    |> list.try_map(int.parse)

  digits
  |> disk_map_from_dense_format
}

/// Part 1 -----------------------------------------------------------------------------------------
pub type Solution1 =
  Int

fn pop_file_from_back(
  disk_map: Deque(Block),
) -> Result(#(Block, Deque(Block)), Nil) {
  case disk_map |> deque.pop_back {
    Error(_) -> Error(Nil)
    Ok(#(FreeBlock, disk_map)) -> pop_file_from_back(disk_map)
    Ok(#(file, disk_map)) -> Ok(#(file, disk_map))
  }
}

fn compact_aux(
  compacted: Deque(Block),
  uncompacted: Deque(Block),
) -> #(Deque(Block), Deque(Block)) {
  case uncompacted |> deque.pop_front {
    // Uncompacted is empty, done. Return #(result, empty).
    Error(_) -> #(compacted, uncompacted)

    // First in uncompacted was a free block...
    Ok(#(FreeBlock, uncompacted)) ->
      // So pop a file from the back to push to result in its place.
      case uncompacted |> pop_file_from_back {
        Error(_) -> #(compacted, uncompacted)
        Ok(#(file, uncompacted)) ->
          // Push file from the back of uncompacted to the back of compacted,
          // to build it in order, and run again.
          compact_aux(compacted |> deque.push_back(file), uncompacted)
      }

    // First in uncompacted was a file...
    Ok(#(file, uncompacted)) ->
      // So just push it to compacted and run again.
      compact_aux(compacted |> deque.push_back(file), uncompacted)
  }
}

fn compact(disk_map: List(Block)) -> List(Block) {
  let #(compacted, _empty) =
    compact_aux(deque.new(), disk_map |> deque.from_list)
  compacted |> deque.to_list
}

fn checksum(disk_map: List(Block)) -> Int {
  disk_map
  |> list.index_map(fn(block, position) {
    case block {
      FileBlock(id) -> position * id
      FreeBlock -> 0
    }
  })
  |> int.sum
}

pub fn solve_part1(input: Input) -> Solution1 {
  input
  |> compact
  |> checksum
}

/// Part 2 -----------------------------------------------------------------------------------------
pub type Solution2 =
  Solution1

type Chunk {
  File(id: Int, size: Int)
  FreeSpace(size: Int)
}

fn into_chunks(disk_map: List(Block)) -> List(Chunk) {
  list.fold(disk_map, [], fn(chunks, block) {
    case block, chunks {
      FileBlock(id), [] -> [File(id, 1)]

      FileBlock(id), [File(previous_id, size), ..rest] if id == previous_id -> {
        [File(previous_id, size + 1), ..rest]
      }

      FileBlock(id), chunks -> [File(id, 1), ..chunks]

      FreeBlock, [FreeSpace(size), ..rest] -> [FreeSpace(size + 1), ..rest]

      FreeBlock, chunks -> [FreeSpace(1), ..chunks]
    }
  })
  |> list.reverse
}

fn into_blocks(disk_map: List(Chunk)) -> List(Block) {
  use chunk <- list.flat_map(disk_map)
  case chunk {
    File(id, size) -> list.repeat(FileBlock(id), times: size)
    FreeSpace(size) -> list.repeat(FreeBlock, times: size)
  }
}

fn with_file_removed(
  disk_map: List(Chunk),
  file_id: Int,
) -> #(Chunk, List(Chunk)) {
  let #(before, rest) =
    disk_map
    |> list.split_while(fn(chunk) {
      case chunk {
        File(id, _) if id == file_id -> False
        _ -> True
      }
    })

  let assert [file, ..after] = rest
  let assert File(_, file_size) = file

  let disk_map = before |> list.append([FreeSpace(file_size), ..after])

  #(file, disk_map)
}

fn padded_file(file: Chunk, free_space_size: Int) -> List(Chunk) {
  let assert File(_, file_size) = file

  case int.compare(file_size, free_space_size) {
    order.Lt -> [file, FreeSpace(free_space_size - file_size)]
    order.Eq -> [file]
    order.Gt -> panic
  }
}

fn with_file_inserted(disk_map: List(Chunk), file: Chunk) -> List(Chunk) {
  let assert File(_, file_size) = file

  let #(before, rest) =
    disk_map
    |> list.split_while(fn(chunk) {
      case chunk {
        FreeSpace(size) if size >= file_size -> False
        _ -> True
      }
    })

  case rest {
    [] -> before |> list.append([file])
    [FreeSpace(free_space_size), ..after] ->
      before
      |> list.append(padded_file(file, free_space_size))
      |> list.append(after)
    [File(_, _), ..] -> panic
  }
}

fn defragment_aux(disk_map: List(Chunk), file_id: Int) -> List(Chunk) {
  use <- bool.guard(when: file_id < 0, return: disk_map)

  let #(file, disk_map) =
    disk_map
    |> with_file_removed(file_id)

  disk_map
  |> with_file_inserted(file)
  |> defragment_aux(file_id - 1)
}

fn defragment(disk_map: List(Block)) -> List(Block) {
  let assert Ok(FileBlock(last_file_id)) = disk_map |> list.last

  disk_map
  |> into_chunks
  |> defragment_aux(last_file_id)
  |> into_blocks
}

pub fn solve_part2(input: Input) -> Solution2 {
  input
  |> defragment
  |> checksum
}

/// Main -------------------------------------------------------------------------------------------
pub fn main() {
  let input = obtain_input(9) |> parse

  io.println("Part 1:")
  solve_part1(input) |> io.debug

  io.println("Part 2:")
  solve_part2(input) |> io.debug
}
