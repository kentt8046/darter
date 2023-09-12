import 'package:darter/darter.dart';

void main(List<String> args) {
  name = "example";
  description = "Example description";

  Task(
    "activate",
    "Compile to executable.",
    (_) => bash("dart compile exe tools/tasks.dart -o /usr/local/bin/$name"),
  );

  Task(
    "read",
    "Input read",
    (_) => bash(r"""
echo -n "Enter your name: "
read name
echo "Hello, $name!"
"""),
  );

  Task(
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

  Task(
    "deps",
    "Task with dependencies.",
    preTasks: [sleep],
    (_) {
      print("deps");
      return 0;
    },
  );

  Task(
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

  Task(
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

  run(args);
}
