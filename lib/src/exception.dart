final class DarterException implements Exception {
  final String message;

  DarterException(this.message);

  @override
  String toString() => message;
}

Never fail(String message) => throw DarterException(message);
