export 'package:h4/src/create_error.dart';
import 'package:h4/src/h4.dart';
import 'package:h4/src/router.dart';

/// Constructs an instance of the `H4` class, which is the main entry point for
/// your application.
///
/// The `H4` constructor initializes the application with an optional port
/// number. If no port is provided, the application will default to using port
/// 3000.
///
/// After creating the `H4` instance, the `start` method is called to begin running the application and listening to requests
///
/// To opt out of this behaviour set `autoStart` property to `false`
///
/// Example usage:
/// ```dart
/// // Start the application on port 8080
/// final app = createApp(port: 8080);
///
/// // Start the application on the default port (3000)
/// final app = createApp();
///
/// // Start the application manually
/// final app = createApp(autoStart: false)
/// await app.start().then((h4) => print('App started on ${h4.port}'))
/// ```
H4 createApp({int port = 3000, bool autoStart = true}) {
  return H4(port: port, autoStart: autoStart);
}

/// Create a router instance for mapping requests.
H4Router createRouter() {
  return H4Router();
}
