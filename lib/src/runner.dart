import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';

import '../darter.dart';

String name = "darter";
String description = "A simple task runner.";

void run(List<String> args, List<Task> tasks) async {
  final runner = CommandRunner(name, description);

  for (final t in tasks) {
    runner.addCommand(_TaskCommand(t));
  }

  int code;
  try {
    code = (await runner.run(args)) ?? 0;
  } on UsageException catch (e) {
    stderr
      ..writeln(e.message)
      ..writeln("")
      ..writeln(e.usage);
    code = 64;
  }

  exit(code);
}

class _TaskCommand extends Command {
  @override
  String get name => task.name;

  @override
  String get description => task.description;

  final Task task;

  final flagNames = <String>[];

  _TaskCommand(this.task) {
    for (final MapEntry(key: name, value: help) in task.flags.entries) {
      final names = name.split(",").map((e) => e.trim());

      String? flagName;
      String? abbr;

      for (final n in names) {
        if (n.startsWith("--")) {
          flagName = n.substring(2);
        } else if (n.startsWith("-")) {
          abbr = n.substring(1);
        } else {
          throw ArgumentError("Invalid flag name: $n");
        }
      }

      if (flagName == null) {
        throw ArgumentError("Invalid flag name: $name");
      }

      argParser.addFlag(flagName, abbr: abbr, help: help);
      flagNames.add(flagName);
    }

    for (final MapEntry(key: define, value: help) in task.options.entries) {
      final parts = define.split("=");
      if (parts.length > 2) {
        throw ArgumentError("Invalid option: $define");
      }

      String? valueHelp;
      var multiple = false;

      final [name, ...valueHelps] = parts;
      if (valueHelps.isNotEmpty) {
        final [help] = valueHelps;
        multiple = help.endsWith("...");
        valueHelp = help.replaceAll("...", "").trim();
      }

      final names = name.split(",").map((e) => e.trim());

      String? optionName;
      String? abbr;

      for (final n in names) {
        if (n.startsWith("--")) {
          optionName = n.substring(2);
        } else if (n.startsWith("-")) {
          abbr = n.substring(1);
        } else {
          throw ArgumentError("Invalid option name: $n");
        }
      }

      if (optionName == null) {
        throw ArgumentError("Invalid option name: $name");
      }

      if (multiple) {
        argParser.addMultiOption(optionName,
            abbr: abbr, help: help, valueHelp: valueHelp);
      } else {
        argParser.addOption(optionName,
            abbr: abbr, help: help, valueHelp: valueHelp);
      }
    }
  }

  @override
  Future<int> run() async {
    final args = argResults!.arguments;

    final flags = Map<String, bool>.unmodifiable(Map.fromEntries(
        flagNames.map((e) => MapEntry(e, argResults![e] ?? false))));

    final options = Map<String, Object?>.unmodifiable(Map.fromEntries(
        argResults!.options
            .where((e) => e != "help" && !flagNames.contains(e))
            .map((e) => MapEntry(e, argResults![e]))));

    final context = Context(
      args: args,
      flags: flags,
      options: options,
    );

    for (final dep in task.deps) {
      print(bold("pre task: ${dep.name}"));
      final code = await dep.action(context);
      if (code != 0) return code;
    }

    print(bold("task: ${task.name}"));
    return task.action(context);
  }
}
