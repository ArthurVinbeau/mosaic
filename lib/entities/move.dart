class Move {
  final int i, j;
  final bool? newState;
  final bool? oldState;

  Move(this.i, this.j, this.oldState, this.newState);

  @override
  String toString() {
    return 'Move{i: $i, j: $j, newState: $newState, oldState: $oldState}';
  }
}
