import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:h4/src/error_middleware.dart';
import 'package:h4/src/h4.dart';

final Map<String, String> _contentTypes = {
  'html': 'text/html',
  'json': 'application/json',
  'text': 'text/plain',
};

void appendDefaultResponseHeader(HttpHeaders responseHeaders, headerValue) {
  responseHeaders.add(HttpHeaders.contentTypeHeader, headerValue);
}

/// Represents an `HTTP request` event in the H4 framework.

// DOC: The H4Event class encapsulates an incoming HTTP request and adds necessary API's to interface with the request and write responses to the client.
class H4Event {
  Map<String, String> params;
  Map<String, dynamic> context;
  dynamic eventResponse;
  final JsonEncoder _jsonEncoder = JsonEncoder.withIndent(' ');

  /// The HTTP request that triggered the event.
  ///
  /// This field is non-nullable and must be provided when creating an `H4Event` instance.
  final HttpRequest _request;

  H4Event(this._request)
      : params = {},
        eventResponse = null,
        context = {
          'path': _request.uri.path,
          'query_params': _request.uri.queryParameters,
          'method': _request.method,
          'protocol': _request.protocolVersion,
        };

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
    var headerValue = _contentTypes[type];
    appendDefaultResponseHeader(_request.response.headers, headerValue);
  }

  /// Sends the HTTP response based on the [handlerResult] and terminates the response stream.
  ///
  /// If [handlerResult] is `null`, the response is closed without sending any content, and the status code is set to 204 (No Content).
  /// After the response is sent, the [handled] flag is set to `true`, indicating that the request has been fully processed.
  void respond(dynamic handlerResult,
      {required void Function(String, String?, H4Event?)? onError,
      required Middleware? afterResponse}) {
    // Handle Async Handler
    if (handlerResult is Future) {
      handlerResult
          .then((value) => _resolveRequest(this, value))
          .onError((error, stackTrace) {
        defineErrorHandler(onError ?? defaultErrorMiddleware,
            params: params,
            error: error.toString(),
            trace: stackTrace)(_request);
      });
      return;
    }

    // Handle non-async handler.
    _resolveRequest(this, handlerResult);

    if (afterResponse != null) {
      afterResponse(this);
    }
  }

  void _writeToClient(dynamic value) {
    _request.response.write(value);
    _shutDown();
  }

  void respondWith(dynamic value) {
    _writeToClient(value);
  }

  /// Will close the native response `IOSink` and stop the response stream.
  void _shutDown() {
    _request.response.close();
  }

  _resolveRequest(H4Event event, handlerResult) {
    event.eventResponse = handlerResult;

    // ignore: type_check_with_null
    if (handlerResult is Null) {
      event.statusCode = 204;
      event.setResponseFormat('null');
      event._writeToClient('No content');
      return;
    }

    if (handlerResult is Map || handlerResult is List || handlerResult is Set) {
      event.setResponseFormat("json");
      handlerResult = _jsonEncoder.convert(handlerResult);
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
