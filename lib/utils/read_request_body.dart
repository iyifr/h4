import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:compute/compute.dart';
import 'package:either_dart/either.dart';
import 'package:h4/src/event.dart';
import 'package:h4/src/logger.dart';


/// Read the body of the request.
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

variableReturnType<T, R>(Either<T, R>? value) {
  return value?.fold((left) => left, (right) => right);
}

parseBodyAsJson({required List<int> bytes}) async {
  var bodyAsDartCollection = await parseJsonString(utf8.decode(bytes));

  // Returns the request body as a dart collection.
  return variableReturnType<Map<dynamic, dynamic>, List<dynamic>>(
      bodyAsDartCollection);
}

FutureOr<Either<Map, List>?> parseJsonString(String jsonString) async {
  if (jsonString.isEmpty) {
    return Left({});
  }

  final parsed = await compute(jsonDecode, jsonString);
  if (parsed is Map) {
    return Left(parsed);
  } else if (parsed is List) {
    return Right(parsed);
  } else {
    logger.severe('Parsed JSON value is not a Map or List: $parsed');
    return null;
  }
}
