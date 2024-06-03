import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'dart:convert';

import 'package:h4/src/trie.dart';
import 'package:h4/src/extract_path_pieces.dart';
import 'package:h4/src/event.dart';

/// A function that takes the following parameters
/// - A [EventHandler] event handler,
/// - A params object that contains the request parameters (if any).
/// - An optional `onRequest` middleware that runs before constructing a response
///
/// It returns a function that is called with a HTTP request, it's job is to write a response and close the request.
///
/// It should always close the request with the appropriate status code and message.
Function(HttpRequest) defineEventHandler(
  EventHandler<dynamic> handler, {
  void Function(H4Event)? onRequest,
  Map<String, String>? params,
}) {
  return (HttpRequest request) {
    // Create an event with the incoming request.
    var event = H4Event(request);

    /// Sets the event params so it accessible in the handler.
    event.eventParams = params ?? {};

    // If onRequest is defined, call it with the event.
    if (onRequest != null) {
      onRequest(event);
    }

    // Call the handler with the event.
    var handlerResult = handler(event);

    if (handlerResult == null) {
      event.setResponseFormat("null");
      event.respond(handlerResult);
      return;
    }

    if (handlerResult is String) {
      event.setResponseFormat("html");
      event.respond(handlerResult);
      return;
    }

    if (handlerResult is DateTime) {
      event.setResponseFormat("text");
      event.respond(handlerResult.toIso8601String());
      return;
    }

    if (handlerResult is Map || handlerResult is List || handlerResult is Set) {
      event.setResponseFormat("json");
      // Encode to jsonString and return
      handlerResult = jsonEncode(handlerResult);
      event.respond(handlerResult);
      return;
    }

    if (handlerResult is Future) {
      handlerResult
          .then((value) => event.respond(value))
          .onError((error, stack) {
        // event.setResponseFormat("json");
        // event.statusCode = 500;
        // var response = {
        //   "message": error.toString(),
        //   "statusCode": 500,
        //   "statusMessage": "Internal Server Error"
        // };
        // event.respond(jsonEncode(response));
      });
      return;
    }

    /// If the [EventHandler] returns a value of type Bool, RegExp, Uri, Symbol or Num set the response format to 'text/plain'
    ///
    /// Serialize the value and send it as a response.
    event.setResponseFormat("text");
    event.respond(handlerResult.toString());
    return;
  };
}

class H4Router {
  Trie routes;

  H4Router([EventHandler? handler]) : routes = Trie(handler);

  /// Handles **GET** requests.
  ///
  /// The event handler will only run if a **GET** request is made to the specified `path`.
  ///
  /// This function is generic, you can specify the return type of your handler by passing a serializable type.
  get<T>(String path, EventHandler<T> handler) {
    routes.insert(extractPieces(path), handler, "GET");
  }

  /// Handles **POST** requests.
  ///
  /// The event handler will only run if a POST request is made to the specified `path`.
  post<T>(String path, EventHandler<T> handler) {
    routes.insert(extractPieces(path), handler, "POST");
  }

  /// Handles `PUT` requests.
  ///
  /// The event handler will only run if a PUT request is made to the specified `path`.
  put<T>(String path, EventHandler<T> handler) {
    routes.insert(extractPieces(path), handler, "PUT");
  }

  /// Handles `PATCH` requests.
  ///
  /// The handler will only run if a **PATCH** request is made to the specified `path`.
  patch<T>(String path, EventHandler<T> handler) {
    routes.insert(extractPieces(path), handler, "PATCH");
  }

  /// Handles `DELETE` request.
  ///
  /// The event handler will only run if a **DELETE** request is made to the specified `path`.
  delete<T>(String path, EventHandler<T> handler) {
    routes.insert(extractPieces(path), handler, "DELETE");
  }

  /// Search through the route prefix tree to find the node holding the handler to our request.
  ///
  /// This returns an object that contains the following:
  /// - A normalized request method string [GET, POST, PUT, DELETE, PATCH]
  Map<String, EventHandler?>? lookup(path) {
    var result = routes.search(extractPieces(path));

    // If we can't find named route, checked for param route.
    result ??= routes.matchParamRoute(extractPieces(path));
    result ??= routes.matchWildCardRoute(extractPieces(path));
    return result;
  }

  Map<String, String> getParams(String path) {
    return routes.getParams(extractPieces(path));
  }
}

/// A function type alias for event handlers in the H4 framework.
///
/// The `EventHandler` type represents a function that takes an [H4Event] as input and
/// returns a `FutureOr<T>`, where `T` is the type of the function response.
///
/// Handlers can be asynchronous and return a Future, or they may not be Future.
/// Hence the FutureOr<T> type.
///
/// Only serializable objects are appropriate return types for handlers
///
/// The supported types are:
/// - Boolean: Sets the content type of the response to text/plain'
/// - String: Sets the content type of the response to 'application/html'
/// - List<T>: A list of items of various types
/// - Map<T>: A standard dart Map.
///
typedef EventHandler<T> = FutureOr<T> Function(H4Event event);
