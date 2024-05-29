import 'dart:io';

// createError([String message = "An error occured"]) {
//   throw H4Exception(message);
// }

class CreateError implements HttpException {
  String _message = "An error occured";
  int _errorCode = 400;

  CreateError(Map<String, dynamic> body) {
    _message = body["message"];
    _errorCode = body["status"];
  }

  @override
  String get message => _message;

  @override
  Uri? get uri => null;

  int get errorCode => _errorCode;
}
