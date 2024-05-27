import 'dart:io';
import '/src/index.dart';
import '/src/trie.dart';
import '/utils/intialize_connection.dart';

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
      HandlerFunc? handler;
      // Find handler for that request
      var match = router!.lookup(request.uri.path);

      var params = router!.getParams(request.uri.path);

      if (match != null) {
        handler = match[request.method];
      }

      if (handler != null) {
        defineEventHandler(handler, params)(request);
      }

      // Handle not found.
      var notFound = defineEventHandler((event) {
        event.statusCode = 404;
        return {"message": "No handler matching route ${event.path}"};
      }, params);

      if (handler == null || match == null) {
        notFound(request);
      }
    });
  }
}
