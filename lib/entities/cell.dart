class Cell {
  int clue;
  bool shown;
  bool value;
  bool full;
  bool empty;
  bool? state;

  Cell({this.clue = 0, this.shown = true, required this.value, this.full = false, this.empty = false, this.state});
}