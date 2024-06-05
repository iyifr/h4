import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:h4/src/logger.dart';

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
        logger.warning('Invalid response format: $type');
    }
  }

  /// Writes the provided [handlerResult] to the HTTP response and closes the response.
  ///
  /// If the [handlerResult] is `null`, the response will be closed without writing any content.
  /// The [handled] flag is set to `true` after the response is sent.
  void respond(dynamic handlerResult) {
    if (_handled) {
      return;
    }

    // Handle Async Handler
    if (handlerResult is Future) {
      handlerResult
          .then((value) => resolveHandler(this, value))
          .onError((error, stackTrace) {
        statusCode = 500;
        var errResponse = {
          "error": error.toString(),
          "statusMessage": "Internal sever error"
        };
        setResponseFormat("json");
        writeToClient(jsonEncode(errResponse));
      });
      return;
    }

    resolveHandler(this, handlerResult);
  }

  /// Avoid using this method in handlers and middleware.
  ///
  /// In handlers return the value instead of writing to the client directly.
  ///
  /// In middleware, your functions should void and not return anything to the client.
  /// They should only run side effects.
  void writeToClient(dynamic value) {
    _request.response.write(value);
    shutDown();
    _handled = true;
  }

  /// Will close the response `IOSink` and complete the request.
  ///
  /// Avoid calling this in handlers and middleware.
  void shutDown() {
    _request.response.close();
  }
}

setEventResponseFormat(H4Event event, handlerResult) {
  if (handlerResult == null) {
    event.setResponseFormat("null");
  } else if (handlerResult is String) {
    event.setResponseFormat("html");
  } else if (handlerResult is Map ||
      handlerResult is List ||
      handlerResult is Set) {
    event.setResponseFormat("json");
  } else {
    event.setResponseFormat('text');
  }
}

resolveHandler(H4Event event, handlerResult) {
  // Don't write anything to the client, shut it down.
  // ignore: type_check_with_null
  if (handlerResult is Null) {
    setEventResponseFormat(event, handlerResult);
    event.shutDown();
  }

  if (handlerResult is Map || handlerResult is List || handlerResult is Set) {
    // Encode to jsonString and return
    setEventResponseFormat(event, handlerResult);
    handlerResult = jsonEncode(handlerResult);
    event.writeToClient(handlerResult);
    return;
  }

  if (handlerResult is DateTime) {
    setEventResponseFormat(event, handlerResult);
    event.writeToClient(handlerResult.toIso8601String());
    return;
  }

  setEventResponseFormat(event, handlerResult);
  event.writeToClient(handlerResult);
}
