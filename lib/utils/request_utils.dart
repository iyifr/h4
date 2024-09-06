import 'dart:io';

import 'package:h4/src/event.dart';

/// Get query the params object from the request URL
///
/// **Example Usage**
///
/// The incoming request path is __/foo?ref=producthunt__
///  ```dart
///
///  router.get('/foo', (event) {
///   // Incoming path --> '/foo?ref=producthunt'
///   var res = getQueryParams(event)
///   var incomingRef = res["ref"] // "producthunt"
/// });
/// ```
getQueryParams(H4Event event) {
  var reqUri = event.node["value"]?.uri.queryParameters;

  return reqUri;
}

/// ### Get a request header by name.
/// Parameters:
/// - `event`: An `H4Event` instance.
/// - `header`: The name of the header to retrieve.
///
/// Returns:
/// The value of the specified header, or `null` if the header is not found.
String? getHeader(H4Event event, String header) {
  return event.node["value"]?.headers.value(header);
}

/// ### Get the request headers object.
//////
/// Parameters:
/// - `event`: An `H4Event` instance containing the HTTP request.
///
/// Returns:
/// The headers of the incoming HTTP request.
HttpHeaders getHeaders(H4Event event) {
  return event.node["value"]!.headers;
}

/// ### Get a request header by name.
/// Parameters:
/// - `event`: An `H4Event` instance.
/// - `header`: The name of the header to retrieve.
///
/// Returns:
/// The value of the specified header, or `null` if the header is not found.
String? getRequestHeader(H4Event event, String header) {
  return event.node["value"]?.headers.value(header);
}

/// ### Get the request headers object.
//////
/// Parameters:
/// - `event`: An `H4Event` instance containing the HTTP request.
///
/// Returns:
/// The headers of the incoming HTTP request.
HttpHeaders getRequestHeaders(H4Event event) {
  return event.node["value"]!.headers;
}
