import 'package:h4/src/event.dart';

/// Get query the params object from the request URL
///
/// **Example Usage**
///
/// The incoming request path is __/foo?ref=producthunt__
///  ```dart
/// ///
///  router.get('/foo', (event) {
///   var res = getQueryParams(event)
///   res["ref"] // "producthunt"
/// });
/// ```
getQueryParams(H4Event event) {
  var reqUri = event.node["value"]?.uri.queryParameters;

  return reqUri;
}
