Ammendment is an Xcode Source Extension containing a set of features that I personally use.

# Features

## Selection

### Select Line 

Select lines where cursors at.

### Select Next

Defaultly, it will select the word next to cusor. Calling this command again will select the next occurrence of previous selected text (works with multiline selections too).

If multiple selections exist, but not all of the selected texts are the same, calling the command again does nothing.

If multiple cursors are added, it will select all words next to cursors.

## Cursor

### Move Cursors 5 Lines Up/Down

Moves all curosrs up / down 5 lines, keeping columns unchanged if possible. 

### Add Cursor Above/Below

Add a cusor above the top most cursor or below the one at bottom, keeping column unchanged if possible. 

## Modification

### Join Lines

Join lines into a single line within one selection, separating by whitesapces.

### Increase / Decrease

Increase / Decrease selected numerics by 1 (for integer) or 0.1 (for floating point).
