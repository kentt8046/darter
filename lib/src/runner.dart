import 'dart:async';
import 'dart:io' hide stdin;

import 'package:args/command_runner.dart';

import '_internal/completion.dart';
import '_internal/stdin.dart';
import 'context.dart';
import 'exception.dart';
import 'style.dart';
import 'task.dart';

String name = "darter";
String description = "A simple task runner.";

void run(List<String> args) async {
  final runner = CommandRunner(name, description)
    ..addCommand(CompletionCommand());

  for (final t in Task.tasks) {
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
  } on DarterException catch (e) {
    stderr.writeln(e.message);
    code = 1;
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
        throw ArgumentError("Invalid flag: $names");
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
      List<String>? allowed;
      var multiple = false;

      final [name, ...valueHelps] = parts;
      if (valueHelps.isNotEmpty) {
        final [help] = valueHelps;
        multiple = help.endsWith("...");
        valueHelp = help.replaceAll("...", "").trim();
        if (valueHelp.startsWith("[") && valueHelp.endsWith("]")) {
          allowed = [
            ...valueHelp
                .substring(1, valueHelp.length - 1)
                .split(",")
                .map((e) => e.trim()),
          ];
          valueHelp = multiple ? "values" : "value";
        }
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
        throw ArgumentError("Invalid option: $names");
      }

      if (multiple) {
        argParser.addMultiOption(optionName,
            abbr: abbr, help: help, valueHelp: valueHelp, allowed: allowed);
      } else {
        argParser.addOption(optionName,
            abbr: abbr, help: help, valueHelp: valueHelp, allowed: allowed);
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
      stdin: stdin,
    );

    final len = task.dependencies.length;
    var i = 1;
    for (final dep in task.dependencies) {
      print(bold("pre task (${i++}/$len): ${dep.name}"));
      final code = await dep.action(context);
      if (code != 0) return code;
    }

    print(bold("task: ${task.name}"));
    return task.action(context);
  }
}
