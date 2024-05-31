import 'package:h4/src/h4.dart';
import 'package:h4/src/index.dart';

// Create an H4 app and optionally pass the port.
H4 createApp({int? port}) {
  return H4(port: port);
}

// Create a router
H4Router createRouter() {
  return H4Router();
}
