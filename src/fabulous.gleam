import gleam/io
import gleam/list
import gleam/string

/// Takes a list of columns (strings), a list of rows (list of strings, each string being a cell), the max width for each cell, the alignment for column names, and alignment for the rows.
/// Valid Alignments: Left, Right, Center (not case sensitive).
pub type Table {
  Table(cols: List(String), rows: List(List(String)), max_width: Int, column_alignment: String, row_alignment: String)
}

/// Adds a column/key to the table; Take current table and new column name. Ensure to add columns before rows.
pub fn add_col(tab: Table, col: String) -> Table {
  let column_ln = string.length(col)

  case column_ln {
    ln if ln > tab.max_width -> panic as "Cannot have column names longer than the max width. Column names don't get wrapped at this time."
    _ -> Nil
  }

  Table(list.append(tab.cols, [col]), tab.rows, tab.max_width, tab.column_alignment, tab.row_alignment)
}

/// Adds a new row to the table. A row is a list of string, each string being the value for that a column (in order of columns). Add rows after and only after adding columns. If you want a value to be empty, include an empty string.
pub fn add_row(tab: Table, row: List(String)) -> Table {
  let col_ln = list.length(tab.cols)

  //Ensuring the rows match the length of columns.
  case list.length(row) {
    ln if ln > col_ln -> panic as {"Cannot have more cells than columns. Additonally, make sure to add columns first. Invlaid Row: [" <> string.join(row, ", ")<>"]"}
    ln if ln < col_ln -> panic as {"Cannot have less cells than columns. If you are want empty cells, include am empty string. Invlaid Row: [" <> string.join(row, ", ")<>"]"}
    _ -> Nil
  }

  // Creating the new table. with the new rows.
  let new_table = Table(tab.cols, list.append(tab.rows, [row]), tab.max_width, tab.column_alignment, tab.row_alignment)

  // Adding a line bracket brake to distinguish rows 
  let line_str = string.join(list.repeat(line_bracket, tab.max_width), "")
  Table(tab.cols, list.append(new_table.rows, [list.repeat(line_str, col_ln)]), tab.max_width, tab.column_alignment, tab.row_alignment) // Updating table to include the line break (gets added as a new row)
  
}

// Border characters
const top_middle_bracket: String = "┬"

const bottom_middle_bracket: String = "┴"

const middle_bracket: String = "┼"

const line_bracket: String = "─"

const top_left_bracket: String = "╭"

const top_right_bracket: String = "╮"

const bottom_left_bracket: String = "╰"

const bottom_right_bracket: String = "╯"

const wall_bracket: String = "│"

const wall_right: String = "├"

const wall_left: String = "┤"

/// Used to print the actual table. Takes a table.
pub fn make_table(tab: Table) -> Nil {

  let aligned_cols = align_columns(tab.column_alignment, tab.cols, tab.max_width) // aligning columns per the determined alignment.
  let tb__char_length = to_length_list(aligned_cols, []) // creating a list of lengths of each column. Used to determine how long to make line segments.
  let col_ln = list.length(tab.cols) // getting the total number of columns

  // Creating and printing the top line of the border. 
  make_top_line(tb__char_length, "")
  |> make_top_border()
  |> io.println()

  // Printing the columns.
  print_entry(aligned_cols, "")
  
  //Creating and printing the comlumn seperator line.
  make_column_line(tb__char_length, "")
  |> make_column_border()
  |> io.println()

  // Wraping rows based on the pre-determined cell width that was passed into the table.
  wrap_rows(split_rows(tab.rows, tab.max_width), col_ln)
  |> align_rows(tab.row_alignment, _, tab.max_width)
  |> print_rows()

  // creating and printing the bottom line of the border.
  make_bottom_line(tb__char_length, "")
  |> make_bottom_border()
  |> io.println()

}

// The following functions could probably be combined since a lot of them do the same stuff, just with different brackets. 

// making the border, inserting the line bracket and middle brackets in between cols.
//for each col, get the col char length, insert * line_brackers and then insert middle_bracket

//FN -> [char length+2]
 fn to_length_list(array: List(String), length_array: List(Int)) -> List(Int) {
  case array {
    [first, ..rest] ->
      to_length_list(
        rest,
        list.append(length_array, [string.length(first) + 2]),
      )
    [] -> length_array
  }
}

//FN loop through array, each loop calling on the make line
 fn make_top_line(array: List(Int), output: String) -> String {
  case array {
    [first, ..rest] -> make_top_line(rest, make_top_line_section(first, output))
    [] -> output
  }
}

//FN to make a segment of the top border line.
 fn make_top_line_section(length: Int, output: String) -> String {
  case length {
    0 -> output <> top_middle_bracket
    _ -> make_top_line_section(length - 1, output <> line_bracket)
  }
}

//FN to finish the line by adding the corner brackers.
 fn make_top_border(line: String) -> String {
  top_left_bracket <> string.drop_end(line, 1) <> top_right_bracket
}

//FN Bottom Line
 fn make_bottom_line(array: List(Int), output: String) -> String {
  case array {
    [first, ..rest] -> make_bottom_line(rest, make_bottom_line_section(first, output))
    [] -> output
  }
}

 fn make_bottom_line_section(length: Int, output: String) -> String {
  case length {
    0 -> output <> bottom_middle_bracket
    _ -> make_bottom_line_section(length - 1, output <> line_bracket)
  }
}

 fn make_bottom_border(line: String) -> String {
  bottom_left_bracket <> string.drop_end(line, 1) <> bottom_right_bracket
}

// Column name line

 fn make_column_line(array: List(Int), output: String) -> String {
  case array {
    [first, ..rest] -> make_column_line(rest, make_column_line_section(first, output))
    [] -> output
  }
}

 fn make_column_line_section(length: Int, output: String) -> String {
  case length {
    0 -> output <> middle_bracket
    _ -> make_column_line_section(length - 1, output <> line_bracket)
  }
}

 fn make_column_border(line: String) -> String {
  wall_right <> string.drop_end(line, 1) <> wall_left
}

//FN to print a actual row, and thus print each cell of that row. Adds a cell wall as well.
 fn print_entry(array: List(String), final: String) -> Nil {
  case array {
    [] -> io.println(wall_bracket <> final)
    [first, ..rest] -> print_entry(rest, final <> " " <> first <> " │")
  }
}

//FN to print each row.
fn print_rows(rows: List(List(String))) -> Nil {
  case rows {
    [first, ..rest] -> {
      print_rows(rest)
      print_entry(first, "")
    }
    [] -> Nil
  }
}

// FN to aling each cell of each row.
fn align_rows(dir: String, rows: List(List(String)), cell_width: Int) -> List(List(String)) {
      list.map(rows, fn(row){ // for every row
        list.map(row, fn(cell){ // and for every cell of said row
          let cell_ln = string.length(cell)

          case cell_ln {
            ln if ln < cell_width -> { // if the length is not the max width
              let spaces_ln = cell_width - cell_ln // determine how much extra room there is

              let spaces = list.repeat(" ", spaces_ln) // create a string with enough spaces to fill the rest of the cell
              |> string.join("")
              
              case string.lowercase(dir) { // conct the cell based on alignment.
                "left" -> cell <> spaces
                "right" -> spaces <> cell
                "center" -> panic as "Center Alignment not implemented yet."
                _ -> panic as "Invalid alignment direction provided."
              }
              
            }
            ln if ln == cell_width -> cell
            _ -> panic as "At this point, the cell length should never be larger the the max cell width. Ensure to run the align function after wrapping rows."
          }
        })
      })
}

//FN to align column names, pretty much same as rows.
fn align_columns(dir: String, cols: List(String), cell_width: Int) -> List(String){
  list.map(cols, fn(col){
    let col_ln = string.length(col)
    case col_ln {
      ln if ln < cell_width -> {
        let spaces_ln = cell_width - col_ln

        let spaces = list.repeat(" ", spaces_ln)
        |> string.join("")

        case string.lowercase(dir) {
          "left" -> col <> spaces
          "right" -> spaces <> col
          "center" -> panic as "Center Alignment not implemented yet."
          _ -> panic as "Invalid alignment direction provided."
        }
      }
      ln if ln == cell_width -> col
      _ -> panic as "At this point, the coloumn length should never be larger the the max cell width. Ensure that the max length of a column accounts for the the longest column name."
    }
  })
}

//The following functions are listed (and were built) from top to down. Each function relies on the function below it. Understanding them might make more sense to read from bottom to top.

// Function to make new entrys for each wrapped row.
 fn wrap_rows(
  splited_rows: List(List(List(String))),
  cols_ln: Int,
) -> List(List(String)) {
  list.map(splited_rows, fn(x) { // for every split row
        
    let str = split_to_rows(x) // Make sure each split row is filled

    let rebo = list.transpose(str) // Transpose it, which merges them kind of, this is where having the split row filled helps keeping the cells aligned.

    list.map(rebo, fn(r) { // for every row
      let r_ln = list.length(r) // get the row length
      case r_ln < cols_ln { // if the row length is short, add empty spaces.
        True -> {
          let spaces = list.repeat(" ", cols_ln - r_ln)
          list.append(spaces, r)
        }
         _ ->  r // other wise return the full row
      }
    })
  })
  |> list.flatten() // get rid of all the extra empty lists that happen becuase of the transpose ( I think)
  |> list.reverse() // Reverse the rows becuase at some point the data got reversed???
  |> list.filter(fn(l){l != list.repeat("", list.length(l))}) // Get rid of all the list of empty strings, that I don't fully understand how they got there.

}

//WHEN IN DOUBT PLAY REPUTATION (Taylors verison if avialable)

//FN (That took a lot of trial and error, hence the above note) that fills every list of sliced strings with empty strings if they don't match the amount of columns. This some how, keeps the sliced cells aligned.
fn split_to_rows(splitted_rows: List(List(String))) -> List(List(String)) {

  list.map(splitted_rows, fn(cell){ // For list of split row, for each split row
    let cell_ln = list.length(cell) // get the cell length
    let sp_ln = list.length(splitted_rows) // get the number of columns (techincally number of split rows, but that should equate to the number of columns)

    case cell_ln < sp_ln { // if the split string is short than the number of columns
      True -> {
        let short_by = sp_ln - cell_ln
        list.append(cell, list.repeat("", short_by)) // fill in the split row with empty strings.
      }
      False -> cell // otherwise, full split row, return it unchanged.
    }
  })

}

// FN to slice every cell (string) in every row.
 fn split_rows(
  rows: List(List(String)),
  max_length: Int,) -> List(List(List(String))) {
  list.map(rows, fn(row) {
    list.map(row, fn(cell) { 
      slice_string(cell, [], max_length) 
      })
  })
}

//FN splits strings into mutiple lines if the they are longer then the cell width.
 fn slice_string(
  s: String,
  cell_list: List(String),
  max_length: Int,
  ) -> List(String) {
    let ln = string.length(s) // Get String length

    case ln > max_length { // If the current cell is wider than the max width
      True -> //than...
        slice_string(
          string.slice(s, max_length, ln), // cut the string (get the max amount possible)
          list.append(cell_list, [string.slice(s, 0, max_length)]), // add it to a new list
          max_length,
        ) // check the remainder of the string
      False -> list.append(cell_list, [string.slice(s, 0, max_length)]) // otherwise return the string (in a list) or return the list of the spliced string.
    }
}
