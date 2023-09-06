import 'dart:async';
import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';

class Aborter {
  final _completer = Completer<int>();

  Future<int> get code => _completer.future;

  void abort(int code) {
    if (_completer.isCompleted) return;
    _completer.complete(code);
  }
}

Future<int> sigterm(Aborter aborter) async {
  late StreamSubscription subscription;
  subscription = ProcessSignal.sigterm.watch().listen((event) async {
    aborter.abort(128 + event.signalNumber);
  });

  return aborter.code.then((value) async {
    await subscription.cancel();
    return value;
  });
}

Future<int> bash(
  String script, {
  String? workingDirectory,
  Map<String, String>? environment,
  bool includeParentEnvironment = true,
  Aborter? aborter,
}) async {
  aborter ??= Aborter();

  final p = await Process.start(
    'bash',
    ['-c', script],
    workingDirectory: workingDirectory,
    environment: environment,
    includeParentEnvironment: includeParentEnvironment,
  );

  final subscriptions = [
    stdin.listen(p.stdin.add),
    p.stdout.listen(stdout.add),
    p.stderr.listen(stderr.add),
  ];

  sigterm(aborter).then((_) {
    p.kill();
  });

  try {
    return p.exitCode;
  } finally {
    aborter.abort(0);
    await Future.wait(subscriptions.map((e) => e.cancel()));
  }
}

Future<int> flow(List<Future<int> Function()> tasks) async {
  for (final task in tasks) {
    final code = await task();
    if (code != 0) return code;
  }
  return 0;
}

Future<int> watch(
  List<String> targets,
  void Function(FileSystemEvent e) onChanged, {
  Aborter? aborter,
  int delaySec = 1,
}) async {
  aborter ??= Aborter();

  var srcList = {
    ...targets
        .where((e) => e.contains("/**"))
        .map((e) => e.replaceFirst(RegExp(r"/\*\*.*"), ""))
  };

  srcList = {...srcList}..removeWhere((src) {
      return srcList.any((e) => src.startsWith("$e/"));
    });

  final patterns = targets.map(Glob.new).toList();
  final subscriptions = <StreamSubscription>[];
  var lastModified = DateTime.now();

  for (final src in srcList) {
    await for (final entity in Glob(src).list(followLinks: true)) {
      subscriptions.add(entity.watch(recursive: true).listen((e) {
        final delta = DateTime.now().difference(lastModified);
        if (delta.inSeconds < delaySec) return;
        if (patterns.any((pattern) => pattern.matches(e.path))) {
          lastModified = DateTime.now();
          onChanged(e);
        }
      }));
    }
  }

  aborter.code.then((value) async {
    await Future.wait(subscriptions.map((e) => e.cancel()));
  });

  return sigterm(aborter);
}
