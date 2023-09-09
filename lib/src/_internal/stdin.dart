import 'dart:async';
import 'dart:io' as io;

final stdin = () {
  final controller = StreamController<List<int>>.broadcast(sync: true);
  io.stdin.pipe(controller);
  return controller.stream;
}();
