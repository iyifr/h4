import 'package:h4/src/event.dart';

setResponseHeader(H4Event event, String header, {required String value}) {
  event.node["value"]?.response.headers.set(header, value);
}
