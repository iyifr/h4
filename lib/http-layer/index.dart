import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'dart:convert';

import 'package:h3/http-layer/trie.dart';
import 'package:h3/utils/extract_path_pieces.dart';
import 'package:h3/http-layer/event.dart';

// Inversion of control, letting the caller define the event. For stuff like reading params.
defineEventHandler(
    FutureOr<dynamic> Function(H4Event event) handler, H4Event ownEvent) {
  return (HttpRequest request) async {
    var handlerResult = handler(ownEvent);

    if (handlerResult == null) {
      ownEvent.setResponseFormatTo("null");
    }

    if (handlerResult.runtimeType == String) {
      ownEvent.setResponseFormatTo("html");
    }

    if (handlerResult is Map<dynamic, dynamic> ||
        handlerResult is List<dynamic>) {
      ownEvent.setResponseFormatTo("json");

      // Encode to jsonString
      handlerResult = jsonEncode(handlerResult);
    }

    ownEvent.respond(handlerResult);
  };
}

class H4Router {
  Trie routes;

  H4Router(HandlerFunc handler) : routes = Trie(handler);

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
    return result;
  }

  Map<String, String> getParams(String path) {
    return routes.getParams(extractPieces(path));
  }
}
