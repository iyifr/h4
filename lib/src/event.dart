import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:h4/src/h4.dart';
import 'package:h4/src/logger.dart';
import 'package:h4/utils/set_response_header.dart';

/// Represents an event in the H4 framework.
///
/// The `H4Event` class encapsulates an HTTP request and provides methods and properties
/// to interact with the request and generate the appropriate response.
class H4Event {
  Map<String, String> params;
  Map<String, dynamic> context;

  /// The HTTP request that triggered the event.
  ///
  /// This field is non-nullable and must be provided when creating an `H4Event` instance.
  final HttpRequest _request;

  /// Tells us whether the event has been handled and a response has been generated.
  bool _handled = false;

  H4Event(this._request)
      : params = {},
        context = {};

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

  /// A way to access the request triggering the event.
  ///
  /// The request is available through node["value"]
  ///
  /// **Read-only***
  ///
  /// You cannot mutate the request directly.
  Map<String, HttpRequest> get node => {'value': _request};

  _isHeaderSet(String header) {
    return _request.response.headers[header] == null ? false : true;
  }

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
    var headers = _request.response.headers;

    if (_isHeaderSet(HttpHeaders.contentTypeHeader)) {
      return;
    }

    switch (type) {
      case 'html':
        headers.add(HttpHeaders.contentTypeHeader, 'text/html');
        break;

      case 'text':
        headers.add(HttpHeaders.contentTypeHeader, 'text/plain');
        break;

      case 'json':
        headers.add(HttpHeaders.contentTypeHeader, 'application/json');
        break;
      case 'null':
        _request.response.statusCode = 204;
        break;
      default:
        logger.warning('Invalid response format: $type');
    }
  }

  /// Writes the provided [handlerResult] to the HTTP response and closes the response.
  ///
  /// If the [handlerResult] is `null`, the response will be closed without writing any content.
  /// The [handled] flag is set to `true` after the response is sent.
  void respond(dynamic handlerResult, {required MiddlewareStack middlewares}) {
    if (_handled) {
      return;
    }

    // Handle Async Handler
    if (handlerResult is Future) {
      handlerResult
          .then((value) => _resolveRequest(this, value))
          .onError((error, stackTrace) {
        // Call error middleware
        if (middlewares != null && middlewares['onError'] != null) {
          middlewares['onError']?.right != null
              ? (
                  '$error',
                  '$stackTrace',
                  this,
                )
              : null;
        }

        statusCode = 500;

        setResponseHeader(this, HttpHeaders.contentTypeHeader,
            value: 'application/json');
        var response = {
          "statusCode": 500,
          "statusMessage": "Internal server error",
          "message": error.toString()
        };

        respondWith(jsonEncode(response));
      });
      return;
    }

    // Handle non-async handler.
    _resolveRequest(this, handlerResult);
  }

  void _writeToClient(dynamic value) {
    _request.response.write(value);
    _shutDown();
    _handled = true;
  }

  void respondWith(dynamic value) {
    _writeToClient(value);
  }

  /// Will close the response `IOSink` and complete the request.
  ///
  /// Avoid calling this in handlers and middleware.
  void _shutDown() {
    _request.response.close();
  }

  _resolveRequest(H4Event event, handlerResult) {
    // ignore: type_check_with_null
    if (handlerResult is Null) {
      event.statusCode = 204;
      event.setResponseFormat('null');
      event._writeToClient('No content');
      return;
    }

    if (handlerResult is Map || handlerResult is List || handlerResult is Set) {
      event.setResponseFormat("json");
      handlerResult = jsonEncode(handlerResult);
      event._writeToClient(handlerResult);
      return;
    }

    // Just in case the user is quirky.
    if (handlerResult is DateTime) {
      event.setResponseFormat('text');
      event._writeToClient(handlerResult.toIso8601String());
      return;
    }

    // Any other data type will be stringified by HttpResponse.write()
    event._writeToClient(handlerResult);
  }
}
