import 'dart:async';

import 'context.dart';

class Task {
  final String name;
  final FutureOr<int> Function(Context context) action;
  final List<Task> deps;
  final String description;
  final Map<String, String> flags;
  final Map<String, dynamic> options;

  const Task(
    this.name,
    this.description,
    this.action, {
    this.deps = const [],
    this.flags = const {},
    this.options = const {},
  });
}
