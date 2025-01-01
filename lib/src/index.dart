import 'dart:core';
import 'dart:io';
import 'package:h4/src/event.dart';
import 'package:h4/src/h4.dart';

/// An internal function that interfaces between the incoming HTTP requests and the H4 interface.
/// 
/// It takes the following arguments.
/// - A [EventHandler] event handler
/// - A params object that contains the request parameters (if any)
/// - An optional `onRequest` middleware that runs before constructing a response
///
/// It returns a function that is called with a HTTP request, it's job is to write a response and close the request.
///
/// It should always close the request with the appropriate status code and message.
Function(HttpRequest) defineEventHandler(
  EventHandler<dynamic> handler,
  MiddlewareStack? middlewares,
  Map<String, String>? params, {
  void Function(H4Event)? onRequest,
}) {
  return (HttpRequest request) {
    var event = H4Event(request);

    /// Sets the event params so it accessible in the handler.
    event.eventParams = params ?? {};

    // If onRequest is defined, call it with the event.
    if (middlewares?['onRequest'] != null) {
      if (middlewares?['onRequest']?.left != null) {
        middlewares?['onRequest']?.left!(event);
      }
    }

    var handlerResult = handler(event);
    event.respond(handlerResult, middlewares: middlewares);
  };
}

/// A type alias for event handlers in the H4 framework.
///
/// `EventHandlers` are used to respond to http request events which are denoted in H4 by `H4Event`.
/// 
/// Event handlers are generic.
typedef EventHandler<T> = T Function(H4Event event);
