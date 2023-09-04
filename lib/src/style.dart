String _decorate(String text, int open, int close) {
  return "\u001B[${open}m$text\u001B[${close}m";
}

String reset(String text) => _decorate(text, 0, 0);

String bold(String text) => _decorate(text, 1, 22);

String black(String text) => _decorate(text, 30, 39);

String red(String text) => _decorate(text, 31, 39);

String green(String text) => _decorate(text, 32, 39);

String yellow(String text) => _decorate(text, 33, 39);

String blue(String text) => _decorate(text, 34, 39);

String magenta(String text) => _decorate(text, 35, 39);

String cyan(String text) => _decorate(text, 36, 39);

String white(String text) => _decorate(text, 37, 39);

String blackBright(String text) => _decorate(text, 90, 39);

String redBright(String text) => _decorate(text, 91, 39);

String greenBright(String text) => _decorate(text, 92, 39);

String yellowBright(String text) => _decorate(text, 93, 39);

String blueBright(String text) => _decorate(text, 94, 39);

String magentaBright(String text) => _decorate(text, 95, 39);

String cyanBright(String text) => _decorate(text, 96, 39);
