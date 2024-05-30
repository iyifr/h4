import 'dart:io';
import 'package:h4/src/create_error.dart';

import '/src/index.dart';
import '/src/trie.dart';
import 'intialize_connection.dart';
import 'event.dart';

typedef Middleware = void Function(H4Event event)?;
typedef MiddleWareObject = Map<String, Middleware>;

class H4 {
  HttpServer? server;
  H4Router? router;
  MiddleWareObject? config;
  Middleware _onRequestHandler;
  int port = 3000;
  void Function(dynamic e, dynamic s) _onErrorHandler =
      (e, s) => print('$e /n $s');

  H4({int? port}) {
    this.port = port ?? 3000;
    start();
  }

  start() async {
    server = await initializeHttpConnection(port: port);
    if (server != null) {
      _bootstrap();
    }
  }

  close([bool force = true]) async {
    await server?.close(force: force);
  }

  use(H4Router router) {
    this.router = router;
  }

  onRequest(Middleware func) {
    _onRequestHandler = func;
  }

  onError(void Function(dynamic e, dynamic s) error) {
    _onErrorHandler = error;
  }

  _bootstrap() {
    server?.listen((HttpRequest request) {
      try {
        HandlerFunc? handler;

        if (router == null) {
          print(
              "No router is defined, did you forget to add a router to your app ?");
        }

        // Find handler for that request
        var match = router?.lookup(request.uri.path);

        var params = router?.getParams(request.uri.path);
        params ??= {};

        if (match != null) {
          handler = match[request.method];
        }

        if (handler != null) {
          defineEventHandler(handler, params, _onRequestHandler)(request);
        }

        // Handle not found.
        var notFound = defineEventHandler((event) {
          event.statusCode = 404;
          return {
            "status": 404,
            "statusMessage": "Not found",
            "message": "No handler found for path - ${event.path}"
          };
        }, params, _onRequestHandler);

        if (handler == null || match == null) {
          notFound(request);
        }
      } on CreateError catch (e) {
        var handleKnownError = defineEventHandler((event) {
          event.statusCode = e.errorCode;
          return {"status": e.errorCode, "message": e.message};
        }, {});
        handleKnownError(request);
      } catch (e, s) {
        _onErrorHandler(e, s);
        var handleUnKnownError = defineEventHandler((event) {
          event.statusCode = 500;
          return {"status": 500, "message": e.toString()};
        }, {});
        handleUnKnownError(request);
      }
    });
  }
}
