# fabulous

[![Package Version](https://img.shields.io/hexpm/v/fabulous)](https://hex.pm/packages/fabulous)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/fabulous/)

```sh
gleam add fabulous@1
```
```gleam
import fabulous

pub fn main() {
   fabulous.Table([], [], 8, "LEFT", "LEFT")
  |> fabulous.add_col("Column 1")
  |> fabulous.add_col("Column 2")
  |> fabulous.add_col("Column 4")
  |> fabulous.add_row(["Row 1", "Cell 2", "Cell 3",])
  |> fabulous.add_row(["This is", "soooo", "loooooooonnnnnngggggg"])
  |> fabulous.make_table()
}
```

Example output:
<pre><code>
╭──────────┬──────────┬──────────╮
│ Column 1 │ Column 2 │ Column 4 │
├──────────┼──────────┼──────────┤
│ Row 1    │ Cell 2   │ Cell 3   │
│ ──────── │ ──────── │ ──────── │
│ This is  │ soooo    │ looooooo │
│          │          │ onnnnnng │
│          │          │ ggggg    │
│ ──────── │ ──────── │ ──────── │
╰──────────┴──────────┴──────────╯
</code></pre>

Further documentation can be found at <https://hexdocs.pm/fabulous>.
## Development
```sh
gleam run   # Run the project
```
