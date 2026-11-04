/// This exception is thrown when an error occurs
/// during Brotli encoding or decoding.
class BrotliException implements Exception {
  /// The exception message.
  final String message;

  /// Instantiates a new [BrotliException] with [message].
  const BrotliException(this.message);

  @override
  String toString() {
    return message;
  }
}
