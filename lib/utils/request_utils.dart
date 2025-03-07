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
///   // Incoming path --> '/foo?ref=product-hunt'
///   var res = getQueryParams(event)
///   var incomingRef = res["ref"] // "product-hunt"
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
///
///
/// Returns:
/// The headers of the incoming HTTP request.
HttpHeaders getRequestHeaders(H4Event event) {
  return event.node["value"]!.headers;
}

/// ### Get a specific cookie by name from the request.
///
/// Parameters:
/// - `event`: An `H4Event` instance containing the HTTP request.
/// - `name`: The name of the cookie to retrieve.
///
/// Returns:
/// The cookie with the specified name, or `null` if not found.
///
/// Example:
/// ```dart
/// final authCookie = getCookie(event, 'auth_token');
/// if (authCookie != null) {
///   print('Auth token: ${authCookie.value}');
/// }
/// ```
Cookie? getCookie(H4Event event, String name) {
  final cookies = event.node["value"]?.cookies;
  if (cookies == null || cookies.isEmpty) return null;

  return cookies.firstWhere(
    (cookie) => cookie.name == name,
  );
}

/// ### Delete a cookie from the client browser
///
/// Parameters:
/// - `event`: An `H4Event` instance containing the HTTP request.
/// - `name`: The name of the cookie to delete.
/// - `path`: Optional path of the cookie (must match the original cookie's path)
/// - `domain`: Optional domain of the cookie (must match the original cookie's domain)
///
/// Example:
/// ```dart
/// deleteCookie(event, 'auth_token');
/// ```
void deleteCookie(H4Event event, String name,
    {String path = '/', String? domain}) {
  final response = event.node["value"]?.response;
  if (response == null) return;
  final cookie = Cookie(name, '');
  cookie.expires = DateTime(1970); // Set expiration to the past
  cookie.maxAge = 0;
  cookie.path = path;
  if (domain != null) {
    cookie.domain = domain;
  }

  response.cookies.add(cookie);
}
