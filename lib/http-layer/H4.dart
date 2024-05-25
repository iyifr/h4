import 'dart:io';
import 'package:h3/http-layer/index.dart';
import 'package:h3/http-layer/trie.dart';
import 'package:h3/http-layer/event.dart';
import 'package:h3/utils/intialize_connection.dart';

class H4 {
  HttpServer? server;
  H4Router? router;

  H4() {
    start();
  }

  start() async {
    server = await initializeHttpConnection();
    if (server != null) {
      _bootstrap();
    }
  }

  use(H4Router router) {
    this.router = router;
  }

  _bootstrap() {
    server?.listen((HttpRequest request) {
      //Transform request to event
      var event = H4Event(request);

      HandlerFunc? handler;

      // Find handler for that request
      var match = router!.lookup(event.path);

      event.params = router!.getParams(event.path);

      if (match == null) {
        defineEventHandler(notFoundHandler, event)(request);
      } else {
        handler = match[event.method];
      }

      if (handler != null) {
        defineEventHandler(handler, event)(request);
      } else {
        defineEventHandler(notFoundHandler, event)(request);
      }
    });
  }
}

H4 createApp() {
  return H4();
}

notFoundHandler(H4Event event) {
  event.statusCode = 404;
  return {"message": "No handler found for ${event.path} - ${event.method}"};
}
