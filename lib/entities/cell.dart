class Cell {
  int clue;
  bool shown;
  bool value;
  bool full;
  bool empty;
  bool? state;
  bool error;
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
