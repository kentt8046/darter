import 'dart:async';
import 'dart:io';

class Aborter {
  final _completer = Completer<int>();

  Future<int> get code => _completer.future;

  void abort(int code) {
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
}) async {
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

  final aborter = Aborter();

  try {
    return await Future.any([
      p.exitCode.whenComplete(() => aborter.abort(0)),
      sigterm(aborter),
    ]);
  } finally {
    await Future.wait(subscriptions.map((e) => e.cancel()));
  }
}
