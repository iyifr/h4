import 'package:h4/src/h4.dart';
import 'package:h4/src/index.dart';

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
/// final app = createApp(port: 8080);
///
/// // Start the application on the default port (3000)
/// final app = createApp();
/// ```
H4 createApp({int? port}) {
  return H4(port: port);
}

/// Create a router instance for mapping requests.
H4Router createRouter() {
  return H4Router();
}
