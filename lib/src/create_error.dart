import 'dart:io';

/// Handles a specific type of error, `CreateError` when it is thrown explicitly in a catch block
///
/// It returns a function that is invoked with the incoming request which sends a JSON payload to the client with the error details.
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
  /// - `errorCode`: The HTTP status code for the error (defaults to 500 if not provided).
  CreateError({
    required this.message,
    this.errorCode = 500,
  });

  @override
  Uri? get uri => null;

  @override
  String toString() {
    return message;
  }
}
