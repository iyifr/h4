import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:h4/src/event.dart';
import 'package:h4/src/h4.dart';
import 'package:h4/src/logger.dart';

/// Read the body of the incoming event request.
/// Returns the request body either as parsed json or a string.
Future<dynamic> readRequestBody(H4Event event) async {
  var request = event.node["value"];

  if (request != null) {
    var parsedBody = await parseRequestBody(request);
    return parsedBody;
  }
}

Future<dynamic> parseRequestBody(HttpRequest request,
    {Duration timeout = const Duration(seconds: 360)}) async {
  var bodyType = request.headers.contentType?.mimeType;

  try {
    var bodyBytes = await request.fold<List<int>>(
      <int>[],
      (previousValue, element) => previousValue..addAll(element),
    ).timeout(timeout);

    // Return different values based on the content type of the request body
    switch (bodyType) {
      case 'application/json':
        return parseBodyAsJson(bytes: bodyBytes);

      case 'text/plain':
        return utf8.decode(bodyBytes);

      default:
        return utf8.decode(bodyBytes);
    }
  } on TimeoutException {
    logger.severe("Timed out while trying to read the request body");
  } catch (e) {
    logger.severe(e.toString());
  }
}

// variableReturnType<T, R>(Either<T, R>? value) {
//   return value?.fold((left) => left, (right) => right);
// }

parseBodyAsJson({required List<int> bytes}) async {
  var body = await parseJsonString(utf8.decode(bytes));

  if (body?.left == null) {
    return body?.right;
  } else {
    return body?.left;
  }
}

FutureOr<Either<Map?, List?>?> parseJsonString(String jsonString) async {
  if (jsonString.isEmpty) {
    return null;
  }

  var parsed = await jsonDecode(jsonString);

  if (parsed is Map) {
    return Either.left(parsed);
  } else if (parsed is List) {
    return Either.right(parsed);
  } else {
    logger.severe('Returned JSON value is not a valid Map or List: $parsed');
    return null;
  }
}
