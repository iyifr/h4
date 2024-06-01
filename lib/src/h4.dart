import 'dart:io';
import 'package:h4/src/create_error.dart';
import 'package:h4/src/logger.dart';

import '/src/index.dart';
import 'intialize_connection.dart';
import 'event.dart';

/// A middleware function that takes an [H4Event] and has access to it's snapshot.
typedef Middleware = void Function(H4Event event)?;

typedef ErrorHandler = void Function(
    {required Object error, required StackTrace stackTrace});

class H4 {
  HttpServer? server;
  H4Router? router;
  Middleware _onRequestHandler;
  // ignore: prefer_function_declarations_over_variables
  void Function(String e, String? s, H4Event? event) _errorHandler =
      (e, s, event) => print('$e/n $s/n ${event?.path}');

  int port = 3000;

  /// Constructs an instance of the `H4` class, which is the main entry point for
  /// your application.
  ///
  /// The `H4` constructor initializes the application with an optional port
  /// number. If no port is provided, the application will default to using port
  /// 3000.
  ///
  /// After creating the `H4` instance, the `start()` method is automatically
  /// called to begin running the application.
  ///
  /// Example usage:
  /// ```dart
  /// // Start the application on port 8080
  /// final app = H4(port: 8080);
  ///
  /// // Start the application on the default port (3000)
  /// final app = H4();
  /// ```
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

  /// Add a [H4Router] to the app instance for mapping requests.
  void use(H4Router router) {
    this.router = router;
  }

  /// Registers a middleware function to be executed on every request.
  ///
  /// This method allows you to pass a `Middleware` function that will be called
  /// for every request in the context of an [H4Event]. The `Middleware` function
  /// is a function that takes an [H4Event] as input and returns a modified
  /// [H4Event].
  ///
  /// The registered middleware function can be used to perform various tasks, such
  /// as:
  ///
  /// - Logging or monitoring requests
  /// - Validating or transforming request data
  /// - Adding headers or other metadata to the request
  /// - Handling cross-cutting concerns like authentication or authorization
  ///
  /// Example usage:
  /// ```dart
  /// h4.onRequest((H4Event event) {
  ///   // Log the request details
  ///   logRequestDetails(event);
  ///
  ///   // Validate the request data
  ///   validateRequestData(event);
  ///
  ///   // Do not return anything from middleware🚫
  ///   // This terminates the request.
  /// });
  /// ```
  void onRequest(Middleware func) {
    _onRequestHandler = func;
  }

  /// Registers an error handling function to be executed when an error occurs.
  ///
  /// This method allows you to pass a function that will be called whenever an
  /// error occurs in the context of an [H4Event]. The provided function will have
  /// access to the following parameters:
  ///
  /// - `String` representation of the error object
  /// - `String` representation of the stack trace
  /// - The [H4Event] that triggered the error (if available)
  ///
  /// This error handling function can be used to log, report, or handle errors in
  /// a custom way within your application.
  ///
  /// Example usage:
  /// ```dart
  /// h4.onError((String error, String stackTrace, H4Event event) {
  ///   // Log the error to a service like sentry.
  ///   logErrorToService(error, stackTrace, event);
  /// });
  /// ```
  void onError(
    void Function(String error, String? stackTrace, H4Event? event)
        errorHandler,
  ) {
    _errorHandler = errorHandler;
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

        if (handler == null || match == null) {
          // Handle not found.
          var notFound = defineEventHandler((event) {
            event.statusCode = 404;
            return {
              "status": 404,
              "statusMessage": "Not found",
              "message":
                  "No handler found for ${event.method.toUpperCase()} request to path - ${event.path}"
            };
          }, params, _onRequestHandler);
          notFound(request);
          return;
        } else {
          defineEventHandler(handler, params, _onRequestHandler)(request);
        }
      } on CreateError catch (e) {
        defineEventHandler((event) {
          event.statusCode = e.errorCode;
          return {"status": e.errorCode, "message": e.message};
        }, {})(request);
      } catch (e, stack) {
        // Handle error middleware.
        H4ErrorHandler(
                handler: _errorHandler,
                trace: stack,
                error: e,
                event: H4Event(request))
            .handle();

        var handleUnKnownError = defineEventHandler((event) {
          event.statusCode = 500;
          return {"status": 500, "message": e.toString()};
        }, {});
        handleUnKnownError(request);
      }
    });
  }
}

/// Handles errors that occur in the context of an [H4Event].
///
/// This class provides a centralized way to manage and handle errors that occur
/// during the execution of an [H4Event]. It encapsulates the error information,
/// including the error object, stack trace, and the event that triggered the
/// error. The class also allows for the registration of an error handling
/// function that can be executed when an error occurs.
class H4ErrorHandler {
  /// The error object that was thrown.
  final Object error;

  /// The stack trace associated with the error.
  final StackTrace trace;

  /// The function that should be executed to handle the error.
  ///
  /// This function will be called with the following parameters:
  /// - `String` representation of the error message
  /// - `String` representation of the stack trace
  /// - The [H4Event] that triggered the error
  final void Function(String, String?, H4Event)? handler;

  /// The [H4Event] that triggered the error.
  final H4Event event;

  /// Constructs a new [H4ErrorHandler] instance.
  ///
  /// The [error], [trace], [handler], and [event] parameters are required.
  H4ErrorHandler({
    required this.error,
    required this.trace,
    required this.handler,
    required this.event,
  });

  /// Executes the registered error handling function.
  ///
  /// If a [handler] function was provided, it will be called with the error
  /// message, stack trace, and the [H4Event] that triggered the error.
  void handle() {
    if (handler != null) {
      handler!(error.toString(), trace.toString(), event);
    }
  }
}
