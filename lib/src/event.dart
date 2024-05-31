import 'dart:core';
import 'dart:io';

/// Represents an event in the H4 framework.
///
/// The `H4Event` class encapsulates an HTTP request and provides methods and properties
/// to interact with the request and generate the appropriate response.
class H4Event {
  Map<String, String> params;

  /// The HTTP request that triggered the event.
  ///
  /// This field is non-nullable and must be provided when creating an `H4Event` instance.
  final HttpRequest _request;

  /// Indicates whether the event has been handled and a response has been generated.
  bool handled = false;

  H4Event(this._request) : params = {};

  String get path => _request.uri.path;

  /// The HTTP method of the request uppercase (e.g., 'GET', 'POST', 'PUT', 'DELETE').
  String get method => _request.method.toUpperCase();

  set statusCode(int code) {
    _request.response.statusCode = code;
  }

  /// Sets the event parameters to the provided [params] map.
  set eventParams(Map<String, String> params) {
    this.params = params;
  }

  /// The status message associated with the HTTP response status code.
  String get statusMessage => _request.response.reasonPhrase;

  /// A way to access the request triggering the event.
  ///
  /// The request is available through node["value"]
  ///
  /// **Read-only***
  ///
  /// You cannot mutate the request directly.
  Map<String, HttpRequest> get node => {'value': _request};

  HttpHeaders get headers => _request.headers;

  /// Sets the response format to the specified [type].
  ///
  /// The supported types are:
  /// - 'html': Sets the content type to 'text/html'
  /// - 'json': Sets the content type to 'application/json'
  /// - 'text': Sets the content type of response to 'text/plain'
  /// - 'null': Sets the status code to 204 (No Content)
  ///
  /// Throws an [ArgumentError] if an invalid [type] is provided.

  void setResponseFormat(String type) {
    switch (type) {
      case 'html':
        _request.response.headers
            .add(HttpHeaders.contentTypeHeader, 'text/html');
        break;
      case 'text':
        _request.response.headers
            .add(HttpHeaders.contentTypeHeader, 'text/plain');
        break;
      case 'json':
        _request.response.headers
            .add(HttpHeaders.contentTypeHeader, 'application/json');
        break;
      case 'null':
        _request.response.statusCode = 204;
        break;
      default:
        throw ArgumentError('Invalid response format: $type');
    }
  }

  /// Writes the provided [handlerResult] to the HTTP response and closes the response.
  ///
  /// If the [handlerResult] is `null`, the response will be closed without writing any content.
  /// The [handled] flag is set to `true` after the response is sent.
  void respond(dynamic handlerResult) {
    if (handlerResult != null) {
      _request.response.write(handlerResult);
    }
    _request.response.close();
    handled = true;
  }
}
