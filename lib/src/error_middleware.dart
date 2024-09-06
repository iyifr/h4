import 'dart:convert';
import 'dart:io';

import 'package:h4/src/event.dart';
import 'package:h4/src/h4.dart';
import 'package:h4/utils/response_utils.dart';

///
/// The `defineErrorHandler` function takes three parameters:
///
/// 1. `_errorHandler`: A void function that will be called to handle the error.
///    This function should have the following signature:
///    `void Function(String, String?, H4Event?)`
/// 2. `params`: An optional `Map<String, String>` containing any parameters
///    associated with the incoming request.
/// 3. `error`: A `String` containing the error message.
/// 4. `trace`: An optional `String` containing the stringified stack trace for the error.
///
/// The `defineErrorHandler` function returns another function that can be
/// called with an `HTTP Request`. When this returned function is called, it will:
///
/// 1. Invoke the provided `_errorHandler` function with the specified
///    parameters, the error message, and the optional stack trace.
/// 2. Generate a JSON payload with the following structure:
///    ```json
///    {
///      "message": "Error message",
///      "statusCode": "500",
///      "statusMessage": "Internal Server Error"
///    }
///    ```
/// 3. Write the JSON payload to the HTTP response and close the response.
///
/// This error handling mechanism is designed to be used in a `catch` block
/// that is specifically catching `CreateError` exceptions. By using a
/// specialized error type, you can provide more targeted and informative
/// error handling for your application.
Function(HttpRequest) defineErrorHandler(ErrorHandler handler,
    {required Map<String, String> params,
    required String error,
    required StackTrace trace,
    int statusCode = 500}) {
  return (HttpRequest request) {
    var event = H4Event(request);
    event.eventParams = params;

    // Call the error middleware.
    handler(error, trace.toString(), event);

    event.statusCode = statusCode;

    setResponseHeader(event,
        header: HttpHeaders.contentTypeHeader, value: 'application/json');
    var response = {
      "statusCode": statusCode,
      "statusMessage": "Internal server error",
      "message": error.toString()
    };

    event.respondWith(jsonEncode(response));
  };
}
