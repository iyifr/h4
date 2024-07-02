import 'dart:io';

import 'package:h4/src/event.dart';

String? getHeader(H4Event event, String header) {
  return event.node["value"]?.headers.value(header);
}

HttpHeaders? getRequestHeaders(H4Event event) {
  return event.node["value"]?.headers;
}

HttpHeaders? getResponseHeaders(H4Event event) {
  return event.node["value"]?.response.headers;
}

String? getResponseHeader(H4Event event, String header) {
  return event.node["value"]?.response.headers.value(header);
}
