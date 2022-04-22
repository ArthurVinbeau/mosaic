import 'package:mosaic/entities/move.dart';

class MoveManager {
  List<List<Move>> _moveHistory;
  int _moveIndex;

  MoveManager()
      : _moveHistory = [],
        _moveIndex = -1;

  bool get canUndo => _moveIndex >= 0;

  bool get canRedo => _moveHistory.isNotEmpty && _moveIndex < _moveHistory.length - 1;

  void add(List<Move> moves) {
    if (canRedo) {
      _moveHistory = _moveHistory.sublist(0, _moveIndex + 1);
    }
    _moveHistory.add(moves);
    _moveIndex++;
  }

  List<Move> undo() => canUndo ? _moveHistory[_moveIndex--] : [];

  List<Move> redo() => canRedo ? _moveHistory[++_moveIndex] : [];
}
