import 'dart:core';
import 'dart:io';
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
    request.response.headers.removeAll(HttpHeaders.contentTypeHeader);

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
    event.respond(handlerResult);
  };
}

/// A function type alias for event handlers in the H4 framework.
///
/// The `EventHandler` type represents a function that takes an [H4Event] as input and
/// returns a `T`, where `T` is the return type of the event handler.
///
/// It represents the type of data you want to send back to the client.
///
/// Only serializable objects are appropriate return types for handlerss
typedef EventHandler<T> = T Function(H4Event event);
