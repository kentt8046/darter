class Context {
  final List<String> args;
  final Map<String, bool> flags;
  final Map<String, dynamic> options;

  Context({
    required this.args,
    required this.flags,
    required this.options,
  });

  @override
  String toString() {
    return "Context(args: $args, flags: $flags, options: $options)";
  }
}
