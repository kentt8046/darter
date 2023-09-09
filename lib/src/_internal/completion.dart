import 'dart:io';

import 'package:args/command_runner.dart';

import '../exception.dart';
import '../runner.dart' as runner;

class CompletionCommand extends Command {
  @override
  final name = "completion";
  @override
  final description = "Generate shell completion scripts.";

  CompletionCommand() {
    argParser
      ..addOption(
        "shell",
        help: "The shell to generate the completion script for.",
        defaultsTo: Platform.environment["SHELL"],
      )
      ..addOption(
        "name",
        abbr: "n",
        help: "The name of the command.",
        defaultsTo: runner.name,
      )
      ..addOption("comp", hide: true);
  }

  @override
  int run() {
    if (tryCompletion()) return 0;

    final shell = argResults!["shell"] as String;
    final name = switch (argResults!["name"]) {
      "" => runner.name,
      final String name => name,
      _ => runner.name,
    };

    print(switch (shell.split("/").last) {
      "zsh" => _generateZsh(name),
      _ => fail("Unsupported shell: $shell"),
    });

    return 0;
  }

  String _generateZsh(String name) => """
_darter() {
  local -a cmds

  IFS=\$'\n'
  cmds=(\$($name completion --comp "\$CURRENT" "\${words[@]}"))
  case \$cmds[1] in
  "commands") _values "commands" \$cmds[2,-1] ;;
  "args") _values "commands" \$cmds[2,-1] ;;
  esac


}

compdef _darter $name
""";

  bool tryCompletion() {
    final current = int.tryParse(argResults!["comp"] ?? "");
    if (current == null) return false;

    // stderr.writeln(current);
    final args = [...argResults!.rest];
    final runner = this.runner!;
    Command? cmd;

    for (final a in args) {
      if (cmd == null && !a.startsWith("-")) {
        cmd = runner.commands[a];
      }
    }

    if (cmd == null) {
      print("commands");
      for (final MapEntry(key: name, value: cmd)
          in this.runner!.commands.entries) {
        print("$name[${cmd.description}]");
      }
    }

    return true;
  }
}
