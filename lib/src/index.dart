import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'dart:convert';

import 'package:h3/src/trie.dart';
import 'package:h3/utils/create_error.dart';
import 'package:h3/utils/extract_path_pieces.dart';
import 'package:h3/src/event.dart';

// Inversion of control, letting the caller define the event. For stuff like reading params.
defineEventHandler(FutureOr<dynamic> Function(H4Event event) handler,
    Map<String, dynamic> params,
    [void Function(H4Event)? onRequest]) {
  return (HttpRequest request) {
    var event = H4Event(request);
    event.params = params;

    if (onRequest != null) {
      onRequest(event);
    }

    var handlerResult = handler(event);

    if (handlerResult == null) {
      event.setResponseFormatTo("null");
    }

    if (handlerResult.runtimeType == String) {
      event.setResponseFormatTo("html");
    }

    if (handlerResult is Map<dynamic, dynamic> ||
        handlerResult is List<dynamic>) {
      event.setResponseFormatTo("json");
      // Encode to jsonString
      handlerResult = jsonEncode(handlerResult);
    }

    if (handlerResult is Future) {
      handlerResult
          .then((value) => event.respond(value))
          .onError((error, stackTrace) {
        request.response.statusCode = 500;
        request.response.write("Internal server error");
        request.response.close();
      });
    } else {
      event.respond(handlerResult);
    }
  };
}

class H4Router {
  Trie routes;

  H4Router([HandlerFunc? handler]) : routes = Trie(handler);

  get(String path, HandlerFunc handler) {
    routes.insert(extractPieces(path), handler, "GET");
  }

  post(String path, HandlerFunc handler) {
    routes.insert(extractPieces(path), handler, "POST");
  }

  Map<String, HandlerFunc?>? lookup(path) {
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
