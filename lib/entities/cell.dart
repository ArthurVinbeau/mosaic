class Cell {
  /// The number of filled cells in the 3x3 square surrounding this cell.
  int clue;

  /// Whether or not the clue should be displayed.
  bool shown;

  /// The value of the cell (true if filled).
  bool value;

  /// Used in generation. True if the 3x3 square is entirely filled (clue == 9).
  bool full;

  /// Used in generation. True if the 3x3 square is entirely empty (clue == 0).
  bool empty;

  /// Current state of the cell. True if filled. False if empty. Null if neither.
  bool? state;

  /// Set to true to highlight an error.
  bool error;

  /// Set to true to show a completed cell.
  bool complete;

  Cell(
      {this.clue = 0,
      this.shown = true,
      required this.value,
      this.full = false,
      this.empty = false,
      this.state,
      this.error = false,
      this.complete = false});

  @override
  String toString() {
    return 'Cell{clue: $clue, shown: $shown, value: $value, full: $full, empty: $empty, state: $state, error: $error, complete: $complete}';
  }
}
