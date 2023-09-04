import 'package:darter/darter.dart';

void main(List<String> args) {
  name = "example";
  run(args, [compile, read, withArgs, sleep, deps, decorate]);
}

final compile = Task(
  "compile",
  "Compile to executable.",
  (_) => bash("dart compile exe example/example.dart -o .dart_tool/example"),
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
