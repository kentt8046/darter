import 'dart:async';

import 'context.dart';

class Task {
  static final tasks = <Task>[];

  final String name;
  final FutureOr<int> Function(Context context) action;
  final List<Task> preTasks;
  final String description;
  final Map<String, String> flags;
  final Map<String, String> options;

  Task(
    this.name,
    this.description,
    this.action, {
    this.preTasks = const [],
    this.flags = const {},
    this.options = const {},
    bool define = true,
  }) {
    if (define) tasks.add(this);
  }
}
