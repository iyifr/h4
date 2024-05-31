import 'dart:io';
import 'package:h4/src/create_error.dart';
import 'package:h4/src/logger.dart';

import '/src/index.dart';
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

  /// Initializes the server on **localhost** and starts listening for requests.
  start() async {
    server = await initializeHttpConnection(port: port);
    _bootstrap();
  }

  /// Shuts down the server and stops listening to requests.
  close({bool force = true}) async {
    await server?.close(force: force);
  }

  /// Add a H4Router that handles request to the server.
  void use(H4Router router) {
    this.router = router;
  }

  void onRequest(Middleware func) {
    _onRequestHandler = func;
  }

  void onError(void Function(dynamic e, dynamic s) error) {
    _onErrorHandler = error;
  }

  _bootstrap() {
    server?.listen((HttpRequest request) {
      try {
        EventHandler? handler;

        if (router == null) {
          logger.w(
              "No router is defined, it is advised to use createRouter() to listen for incoming requests.");
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
