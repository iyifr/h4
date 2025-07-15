import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:h4/src/create_error.dart';
import 'package:h4/src/event.dart';
import 'package:h4/src/logger.dart';
import 'package:h4/utils/formdata.dart';
import 'package:h4/utils/req_utils.dart' as req_utils;

/// Read the incoming HTTP event request body.
/// Generically typed.
///
/// Prefer setting `T` as `List<dynamic>` or `Map<String, dynamic>` or `List<Map<String, dynamic>` and then casting the returned json body to avoid type errors.
Future<T?> readRequestBody<T>(H4Event event) async {
  var request = event.node["value"]!;

  var parsedBody = await parseRequestBody<T>(request);
  return parsedBody;
}

FutureOr<T?> parseRequestBody<T>(HttpRequest request,
    {Duration timeout = const Duration(seconds: 360)}) async {
  try {
    var bodyType = request.headers.contentType?.mimeType;
    Stream<int> byteStream = request.expand((e) => e.toList());

    List<int> bodyBytes = await byteStream.toList();

    if (bodyBytes.isEmpty) {
      return null;
    }

    // Return different values based on the content type of the request body
    switch (bodyType) {
      case 'application/json':
        return parseBodyAsJson<T>(bytes: bodyBytes);

      case 'text/plain':
        return Future.microtask(() => utf8.decode(bodyBytes) as T).catchError(
            (e) => throw CreateError(
                message: 'Error reading request body', errorCode: 500));

      case 'multipart/form-data':
        var boundary = request.headers.contentType?.parameters["boundary"];
        var formData = FormData();
        var result = await req_utils.handleMultipartFormdata(
            request, boundary!, formData) as T;
        return result;
      default:
        throw UnsupportedError(
            "Unsupport request type in request body stream $bodyType");
    }
  } on TimeoutException {
    logger.severe("Timed out while trying to read the request body");
    throw TimeoutException("Timed out while trying to read request body");
  } catch (e) {
    logger.severe(e.toString());
    rethrow;
  }
}

T? parseBodyAsJson<T>({required List<int> bytes}) {
  var body = utf8.decode(bytes);
  var trimmedBody = body.trim();

  // Decode JSON
  var decoded = json.decode(trimmedBody);

  // Handle array case
  if (trimmedBody.startsWith('[')) {
    if (T == List<String>) {
      return (decoded as List).cast<String>() as T;
    } else if (T == List<Map<String, dynamic>>) {
      return (decoded as List).cast<Map<String, dynamic>>() as T;
    } else if (T == List) {
      return (decoded as List).cast<dynamic>() as T;
    } else if (T == List<double>) {
      return convertToList(decoded, convertToDouble) as T;
    }
    return decoded as T;
  }

  // Handle map/object case
  if (trimmedBody.startsWith('{')) {
    if (T == Map<String, dynamic>) {
      return (decoded as Map<String, dynamic>) as T;
    }
    if (T == Map<String, int>) {
      return convertToMapStringInt(decoded) as T;
    }
  }

  throw FormatException('JSON body must be an object or array');
}

/// Type converter function signature for converting JSON values
typedef JsonConverter<T> = T Function(dynamic json);

/// Parse JSON body with custom type conversion
T? parseBodyWithConverter<T>(List<int> bytes, JsonConverter<T> converter) {
  var body = utf8.decode(bytes);

  // Decode JSON
  var decoded = json.decode(body);

  try {
    // Apply converter to decoded JSON
    return converter(decoded);
  } catch (e) {
    throw FormatException('Failed to convert JSON to type $T: ${e.toString()}');
  }
}

/// Common converter functions
Map<String, int> convertToMapStringInt(dynamic json) {
  if (json is! Map) throw FormatException('JSON must be an object');
  return Map<String, int>.fromEntries(json.entries
      .map((e) => MapEntry(e.key.toString(), int.parse(e.value.toString()))));
}

Map<String, String> convertToMapStringString(dynamic json) {
  if (json is! Map) throw FormatException('JSON must be an object');
  return Map<String, String>.fromEntries(
      json.entries.map((e) => MapEntry(e.key.toString(), e.value.toString())));
}

List<T> convertToList<T>(dynamic json, T Function(dynamic) itemConverter) {
  print(json);
  if (json is! List) throw FormatException('JSON must be an array');
  return json.map((item) => itemConverter(item)).toList();
}

double convertToDouble(dynamic json) {
  if (json is num) {
    return json.toDouble();
  }
  if (json is String) {
    return double.parse(json);
  }
  throw FormatException('Value cannot be converted to double: $json');
}

Map<String, Type> map = {'double': double};
