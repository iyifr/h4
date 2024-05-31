import 'dart:io';

class CreateError implements HttpException {
  @override

  /// Message to send to client.
  final String message;

  /// HTTP status code (defaults to 400).
  final int errorCode;

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
