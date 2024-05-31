import 'dart:io';

class CreateError implements HttpException {
  @override
  final String message;
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
