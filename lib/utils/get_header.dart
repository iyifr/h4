import 'dart:io';

import 'package:h4/src/event.dart';

/// ### Retrieves the value of a specific header from an event instance.
///
/// The `getHeader` function is used to extract the value of a specified header from an `H4Event` object. The `H4Event` object is expected to have a `node` property that contains an HTTP request, and the `node["value"]` property is assumed to represent the incoming HTTP request.
///
/// Parameters:
/// - `event`: An `H4Event` instance.
/// - `header`: The name of the header to retrieve.
///
/// Returns:
/// The value of the specified header, or `null` if the header is not found.
String? getHeader(H4Event event, String header) {
  return event.node["value"]?.headers.value(header);
}

/// Retrieves the headers of the incoming HTTP request from an `H4Event` instance.
///
/// The `getRequestHeaders` function is used to extract the headers of the incoming HTTP request from an `H4Event` object. The `H4Event` object is expected to have a `node` property that contains the HTTP request, and the `node["value"]` property is assumed to represent the incoming HTTP request.
///
/// Parameters:
/// - `event`: An `H4Event` instance containing the HTTP request.
///
/// Returns:
/// The headers of the incoming HTTP request.
HttpHeaders? getRequestHeaders(H4Event event) {
  return event.node["value"]?.headers;
}

/// Retrieves the headers of the HTTP response from an `H4Event` instance.
///
/// The `getResponseHeaders` function is used to extract the headers of the HTTP response from an `H4Event` object. The `H4Event` object is expected to have a `node` property that contains the HTTP request, and the `node["value"]` property is assumed to represent the incoming HTTP request.
///
/// Parameters:
/// - `event`: An `H4Event` instance containing the HTTP request.
///
/// Returns:
/// The headers of the HTTP response, or `null` if the response is `null`.
HttpHeaders? getResponseHeaders(H4Event event) {
  return event.node["value"]?.response.headers;
}

/// Retrieves the value of a specific header in the HTTP response from an `H4Event` instance.
///
/// The `getResponseHeader` function is used to extract the value of a specified header from the HTTP response of an `H4Event` object. The `H4Event` object is expected to have a `node` property that contains the HTTP request, and the `node["value"]` property is assumed to represent the incoming HTTP request.
///
/// Parameters:
/// - `event`: An `H4Event` instance containing the HTTP request.
/// - `header`: The name of the header to retrieve.
///
/// Returns:
/// The value of the specified header, or `null` if the header is not found or the response is `null`.
String? getResponseHeader(H4Event event, String header) {
  return event.node["value"]?.response.headers.value(header);
}
