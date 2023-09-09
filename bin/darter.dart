import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:args/command_runner.dart';
import 'package:darter/darter.dart';
import 'package:darter/src/_internal/completion.dart';

final taskFile = File("${Directory.current.path}/tools/tasks.dart");

Future<void> main(List<String> args) async {
  if (await taskFile.exists()) {
    final onExit = ReceivePort();
    await Isolate.spawnUri(
      taskFile.uri,
      args,
      null,
      onExit: onExit.sendPort,
    );

    await onExit.first;
    return;
  }

  final runner = CommandRunner("darter", "A simple task runner.")
    ..addCommand(InitCommand())
    ..addCommand(CompletionCommand());

  int code;
  try {
    await runner.run(args);
    code = 0;
  } on UsageException catch (e) {
    stderr
      ..writeln(e.message)
      ..writeln("")
      ..writeln(e.usage);
    code = 0;
  } on DarterException catch (e) {
    stderr.writeln(e.message);
    code = 1;
  }

  exit(code);
}

class InitCommand extends Command {
  @override
  final name = "init";

  @override
  final description = "Initialize a new `tasks.dart`.";

  InitCommand() {
    argParser.addFlag(
      "force",
      abbr: "f",
      help: "Force overwrite if `tasks.dart` already exists.",
      defaultsTo: false,
    );
  }

  @override
  Future<void> run() async {
    final force = argResults!["force"] as bool;

    if (!force && await taskFile.exists()) {
      fail("tools/tasks.dart already exists.");
    }

    await Directory("tools").create(recursive: true);
    await taskFile.writeAsString(tasksFile);
  }
}

const tasksFile = r'''
import 'package:darter/darter.dart';

void main(List<String> args) {
  name = "example";
  description = "Example description";
  run(args, [activate, read, withArgs, sleep, deps, decorate, watchSources]);
}

final activate = Task(
  "activate",
  "Compile to executable.",
  (_) => bash("dart compile exe tools/tasks.dart -o /usr/local/bin/$name"),
);

final read = Task(
  "read",
  "Input read",
  (_) => bash(r"""
echo -n "Enter your name: "
read name
echo "Hello, $name!"
"""),
);

final withArgs = Task(
  "with-args",
  "Task with args, flags and options.",
  flags: {
    "-f,--flag": "Flag description",
  },
  options: {
    "-o,--option": "Option description",
    "-m,--multiple=values...": "Multiple option description",
    "--allowed=[a,b,c]": "Allowed option description",
    "--multiple-allowed=[a,b,c]...": "Multiple allowed option description",
  },
  (context) {
    print(context);
    return 0;
  },
);

final sleep = Task(
  "sleep",
  "Sleep 3 seconds.",
  (_) async {
    print("sleep 3 seconds...");
    await Future.delayed(Duration(seconds: 3));
    print("awake");
    return 0;
  },
);

final deps = Task(
  "deps",
  "Task with dependencies.",
  deps: [sleep],
  (_) {
    print("deps");
    return 0;
  },
);

final decorate = Task(
  "decorate",
  "Decorate text.",
  (context) {
    print([
      bold("bold"),
      black("black"),
      red("red"),
      green("green"),
      yellow("yellow"),
      blue("blue"),
      magenta("magenta"),
      cyan("cyan"),
      white("white"),
      blackBright("blackBright"),
      redBright("redBright"),
      greenBright("greenBright"),
      yellowBright("yellowBright"),
      blueBright("blueBright"),
      magentaBright("magentaBright"),
      cyanBright("cyanBright"),
    ].join(" "));
    return 0;
  },
);

final watchSources = Task(
  "watch",
  "Watch sources.",
  (_) {
    return watch(
      ["lib/**"],
      (e) {
        print(e);
      },
    );
  },
);
''';
