import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<String> parseRequestBody(HttpRequest request,
    {Duration timeout = const Duration(seconds: 60)}) async {
  // if (request.headers.contentType?.mimeType != 'application/json') {
  //   throw FormatException(
  //       'Unsupported content type: ${request.headers.contentType}');
  // }

  try {
    var bodyBytes = await request.fold<List<int>>(
      <int>[],
      (previousValue, element) => previousValue..addAll(element),
    ).timeout(timeout);

    if (bodyBytes.isEmpty) {
      return '';
    }

    return utf8.decode(bodyBytes);
  } catch (e) {
    if (e is TimeoutException) {
      throw TimeoutException('Request body parsing timed out after $timeout');
    } else {
      throw FormatException('Error decoding request body: $e');
    }
  }
}
