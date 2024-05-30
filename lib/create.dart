import 'package:h4/src/h4.dart';
import 'package:h4/src/index.dart';

H4 createApp({int? port}) {
  return H4(port: port);
}

H4Router createRouter() {
  return H4Router();
}
