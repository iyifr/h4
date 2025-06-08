import 'dart:io';
import 'package:h4/src/create_error.dart';
import 'package:h4/src/error_middleware.dart';
import 'package:h4/src/logger.dart';
import 'package:h4/src/port_taken.dart';
import 'package:h4/src/router.dart';
import 'package:h4/utils/response_utils.dart';

import '/src/index.dart';
import 'initialize_connection.dart';
import 'event.dart';

class Either<T, U> {
  final T? left;
  final U? right;

  Either.left(this.left) : right = null;
  Either.right(this.right) : left = null;
}

void Function(String error, String? stackTrace, H4Event? event)
    defaultErrorMiddleware = (error, stackTrace, event) => logger.severe(
        '$error\n$stackTrace Error occured while attempting ${event?.method.toUpperCase()} request at - ${event?.path}');

/// A middleware function that takes an [H4Event] and has access to it's snapshot.
/// Can also
typedef Middleware = void Function(H4Event event)?;

/// The [ErrorHandler] is used to process and potentially report errors that occur
/// during the execution of the application.
///
/// Parameters:
/// - [String] errorMessage: A description of the error that occurred.
/// - [String?] stackTrace: The stack trace associated with the error, if available.
///   This parameter is optional and may be null.
/// - [H4Event?] event: An optional event object that provides additional context
///   about when or where the error occurred. This parameter is optional and may be null.
///
typedef ErrorHandler = void Function(String, String?, H4Event?);

// Workaround for union types.
typedef MiddlewareStack = Map<String, Either<Middleware?, ErrorHandler?>?>?;

class H4 {
  HttpServer? server;
  H4Router? router;
  Map<String, H4Router> routeStack = {};
  late MiddlewareStack middlewares;

  // ignore: prefer_function_declarations_over_variables

  int port;

  /// Constructs an instance of the `H4` class, which is the main entry point for
  /// your application.
  ///
  /// The `H4` constructor initializes the application with an optional port
  /// number. If no port is provided, the application will default to using port
  /// 3000.
  ///
  ///
  /// After creating the `H4` instance, the `start()` method is automatically
  /// called to begin running the application.
  ///
  /// To opt out of this behaviour set `autoStart` property to `false`
  ///
  /// Example usage:
  /// ```dart
  /// // Start the application on port 8080
  /// final app = H4(port: 8080);
  ///
  /// // Start the application on the default port (3000)
  /// final app = H4();
  /// ```
  H4({
    this.port = 3000,
    bool autoStart = true,
    this.middlewares,
  }) {
    if (autoStart) {
      start(port: port);
    }

    initLogger();
  }

  /// Initializes the server on an available localhost port and starts listening for requests.
  Future<H4?> start({required int port}) async {
    try {
      bool portReady = await isPortAvailable(port: port);

      while (portReady == false) {
        port += 1;
        portReady = await isPortAvailable(port: port);
      }

      server = await initializeHttpConnection(
        port: port,
      );
      _bootstrap();
      logger.info('Server started on port $port');
      return this;
    } catch (e) {
      logger.severe(e.toString());
      return null;
    }
  }

  /// Shuts down the server and stops listening to requests.
  close({bool force = true}) async {
    await server?.close(force: force);
  }

  /// Adds a `Router` to the app instance for mapping requests to a path.
  ///
  /// The _basePath_ parameter allows you to mount the router at a specific URL prefix.
  /// All routes defined in the router will be relative to this base path.
  ///
  /// Example usage:
  /// ```dart
  /// void main() {
  ///   var app = createApp(port: 3000);
  ///
  ///   // Create routers
  ///   var mainRouter = createRouter();
  ///   var apiRouter = createRouter();
  ///
  ///   // Mount routers with different base paths
  ///   app.use(mainRouter, basePath: '/');      // Handles routes like '/', '/about'
  ///   app.use(apiRouter, basePath: '/api');    // Handles routes like '/api/users'
  ///
  ///   // Define routes
  ///   mainRouter.get('/hello', (event) => 'Hello World');
  ///   apiRouter.get('/users', (event) => ['user1', 'user2']);
  /// }
  /// ```
  void use(H4Router router, {String basePath = '/'}) {
    routeStack[basePath] = router;
    this.router = router;
  }

  /// Registers a middleware function to be executed on every request.
  ///
  /// This method allows you to pass a `Middleware` function that will be called
  /// for every request in the context of an [H4Event]. The `Middleware` function
  /// is a function that takes an [H4Event] as input and returns a modified
  /// [H4Event].
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
  ///   // Validate the request data
  ///   validateRequestData(event);
  /// });
  /// @deprecated
  /// ```
  @Deprecated('Set the middlewares in the create app constructor instead')
  void onRequest(Middleware func) {
    return;
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
  /// Example usage:
  /// ```dart
  /// h4.onError((String error, String stackTrace, H4Event event) {
  ///   // Log the error to a service like sentry.
  ///   logErrorToService(error, stackTrace, event);
  /// });
  /// ```
  @Deprecated('Set your middlewares in the app init function instead')
  void onError(
    void Function(String error, String? stackTrace, H4Event? event)
        errorHandler,
  ) {
    null;
  }

  _bootstrap() {
    server!.listen((HttpRequest request) {
      if (routeStack.values.isEmpty) {
        logger.warning("No router instances found.");
        return404(request)(middlewares, null);
        return;
      }

      H4Router? hRouter = routeStack['/'];
      String routeKey = '/';

      for (var key in routeStack.keys) {
        if (!key.startsWith('/')) {
          logger.severe(
              'Invalid base path! - found $key - change the base path to /$key');
        }

        if (request.uri.path.startsWith(key)) {
          hRouter = routeStack[key];
          routeKey = key;
        }
      }

      var incomingReqPath = request.uri.path;

      if (routeKey != '/') {
        incomingReqPath = incomingReqPath.replaceFirstMapped(
            routeKey, (m) => m.toString() == routeKey ? '/' : '');
      }

      // Find handler for that request
      var match = hRouter?.lookup(incomingReqPath);

      var params = hRouter?.getParams(incomingReqPath);
      params ??= {};

      // Handling starts here.
      try {
        EventHandler? handler;

        if (match == null) {
          return404(request)(middlewares, null);
          return;
        }

        handler = match[request.method];

        bool otherMethodsInTheRoute = match.keys.isNotEmpty; // isEmpty // If the incoming HTTP request path has a eventHandler regisntered in the router but for another HTTP method.
        bool containsALLRoute = match.containsKey("ALL");

        if (handler == null) {
          if (containsALLRoute) {
            defineEventHandler(match["ALL"]!, middlewares, params);
          }

          if (otherMethodsInTheRoute) {
            return405(request)(middlewares, null, match);
            return;
          }
           else {
            return404(request)(middlewares, null);
            return;
          }
        }
        defineEventHandler(handler, middlewares, params)(request);
      }

      // Catch `createError` exception.
      on CreateError catch (e, trace) {
        defineErrorHandler(
            middlewares?['onError']?.right ?? defaultErrorMiddleware,
            params: params,
            error: e.message,
            trace: trace,
            statusCode: e.errorCode)(request);
      }

      // Catch `throw` type exceptions
      catch (e, trace) {
        defineErrorHandler(
            middlewares?['onError']?.right ?? defaultErrorMiddleware,
            params: params,
            error: e.toString(),
            trace: trace,
            statusCode: 500)(request);
      }
    });
  }
}

typedef NotFoundHandler = dynamic Function(
    MiddlewareStack stack, Map<String, String>? params);

NotFoundHandler return404(HttpRequest request) {
  return (
    stack,
    params,
  ) {
    return defineEventHandler(
      (event) {
        event.statusCode = 404;
        setResponseHeader(event,
            header: HttpHeaders.contentTypeHeader, value: 'application/json');
        return {
          "statusCode": 404,
          "statusMessage": "Not found",
          "message":
              "Failed to ${event.method.toUpperCase()} at ${event.path}, PATH not found."
        };
      },
      stack,
      params,
    )(request);
  };
}

typedef MethodNotAllowedHandler = dynamic Function(
    MiddlewareStack stack,
    Map<String, String>? params,
    Map<String, dynamic Function(H4Event)?>? match);

MethodNotAllowedHandler return405(HttpRequest request) {
  return (stack, params, match) {
    return defineEventHandler(
      (event) {
        event.statusCode = 405;
        setResponseHeader(event,
            header: HttpHeaders.contentTypeHeader, value: 'application/json');

        setResponseHeader(event,
            header: HttpHeaders.allowHeader,
            value: match?.keys.join(',') ?? "");
        return {
          "statusCode": 405,
          "statusMessage": "Method Not Allowed",
          "message":
              "Failed to ${event.method.toUpperCase()} ${event.path}, Method not allowed."
        };
      },
      stack,
      params,
    )(request);
  };
}
