import 'dart:io';

// createError([String message = "An error occured"]) {
//   throw H4Exception(message);
// }

class CreateError implements HttpException {
  String _message = "An error occured";
  int _errorCode = 400;

  CreateError(String message, [int? status]) {
    _message = message;
    _errorCode = status ?? 400;
  }

  @override
  String get message => _message;

  @override
  Uri? get uri => null;

  @override
  String toString() {
    return '$_errorCode - $_message';
  }

  int get errorCode => _errorCode;
}
