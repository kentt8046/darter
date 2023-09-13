final class Context {
  final List<String> args;
  final Map<String, bool> flags;
  final Map<String, dynamic> options;
  final Stream<List<int>> stdin;

  Context({
    required this.args,
    required this.flags,
    required this.options,
    required this.stdin,
  });

  @override
  String toString() {
    return "Context(args: $args, flags: $flags, options: $options)";
  }
}
