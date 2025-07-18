export 'package:h4/src/create_error.dart';
export 'package:h4/utils/req_utils.dart';
export 'package:h4/utils/response_utils.dart';
export 'package:h4/utils/body_utils.dart';
export 'package:h4/src/event.dart';
import 'package:h4/src/h4.dart';
import 'package:h4/src/router.dart';

/// Constructs an instance of the `H4` class, which is the main entry point for
/// your application.
///
/// It initializes the application with the provided configuration and optionally
/// starts it on the specified [port].
///
/// Parameters:
/// - [port]: The HTTP port to start the application on. Defaults to 3000.
/// - [autoStart]: Whether to immediately start the app once invoked. If set to `false`,
///   you must start the app manually by calling `app.start()`. Defaults to true.
/// - [onRequest]: A middleware function to handle incoming requests before they are
///   processed by the main application logic.
/// - [onError]: An error handler function to process and report errors that occur
///   during the execution of the application.
/// - [afterResponse]: A middleware function to handle outgoing responses before they
///   are sent back to the client.
///
/// Returns:
/// An instance of [H4] configured with the provided parameters.
///
/// Example usage:
/// ```dart
/// // Start the application on port 8080
/// final app = createApp(port: 8080);
/// ```
H4 createApp({
  /// The HTTP port to start the application on
  int port = 3000,

  /// Whether to immediately start the app once invoked.
  /// If set to `false`, you must start the app manually by calling `app.start()`
  bool autoStart = true,

  /// Middleware function to handle incoming requests
  Middleware? onRequest,

  /// Error handler function to process and report errors
  ///
  /// Parameters:
  /// - [String] errorMessage: A description of the error that occurred.
  /// - [String?] stackTrace: The stack trace associated with the error, if available.
  /// - [H4Event?] event: The event object that provides additional context
  ///   about the request being processed when the error occurred.
  ErrorHandler? onError,

  /// Middleware function to handle outgoing responses
  Middleware? afterResponse,
}) {
  MiddlewareStack middlewares = {
    'onRequest': Either.left(onRequest),
    'onError': Either.right(onError),
    'afterResponse': Either.left(afterResponse),
  };

  return H4(port: port, autoStart: autoStart, middlewares: middlewares);
}

/// Create a router instance for mapping requests.
H4Router createRouter() {
  return H4Router();
}
