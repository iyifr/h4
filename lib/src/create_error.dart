import 'dart:io';

/// Custom HTTP exception class for creating and throwing errors.
class CreateError implements HttpException {
  /// Message to send to the client.
  @override
  final String message;

  /// HTTP status code (defaults to 400).
  final int errorCode;

  /// Constructs a `CreateError` instance.
  ///
  /// Throws a custom error with the provided message and optional HTTP status code.
  ///
  /// Parameters:
  /// - `message`: The error message to be sent to the client.
  /// - `errorCode`: The HTTP status code for the error (defaults to 400 if not provided).
  CreateError({
    required this.message,
    this.errorCode = 400,
  });

  @override
  Uri? get uri => null;

  @override
  String toString() {
    return '$errorCode - $message';
  }
}
