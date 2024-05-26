import 'dart:core';
import 'dart:io';

class H4Event {
  H4Event(this._request);
  Map<String, dynamic>? params;

  final HttpRequest _request;
  bool handled = false;

// Methods, getters and setters
  String get path => _request.uri.path;

  String get method => _request.method.toUpperCase();

  set statusCode(int code) {
    _request.response.statusCode = HttpStatus.notFound;
  }

  set eventParams(Map<String, dynamic> params) {
    this.params = params;
  }

  Map<String, HttpRequest> get node => {'value': _request};

  HttpHeaders get headers => _request.headers;

  setResponseFormatTo(String type) {
    switch (type) {
      case 'html':
        _request.response.headers
            .add(HttpHeaders.contentTypeHeader, "text/html");

      case 'json':
        _request.response.headers
            .add(HttpHeaders.contentTypeHeader, "application/json");

      case 'null':
        _request.response.statusCode = 204;
    }
  }

  respond(dynamic handlerResult) {
    _request.response.write(handlerResult);
    _request.response.close();
    handled = true;
  }
}
