import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:h4/create.dart';
import 'package:mime/mime.dart';

export 'package:h4/utils/req_utils.dart' hide handleMultipartFormdata, FormData;

String? getRequestIp(H4Event event) {
  var ip = event.node["value"]?.headers
      .value("x-forwarded-for")
      ?.split(',')[0]
      .trim();

  ip ??= event.node["value"]!.connectionInfo?.remoteAddress.address;

  return ip;
}

/// **Get incoming request host**
///
/// Either **http** or **https**
String? getRequestHost(H4Event event) {
  return event.node["value"]?.headers.value(HttpHeaders.hostHeader);
}

/// #### Get the full request URL.
///
/// ```dart
/// router.get("/home", (event) => {
///   var url = getRequestUrl(event) // https://app-client-url.com/products
/// })
/// ```
String? getRequestUrl(H4Event event) {
  return '${getRequestProtocol(event)}://${getRequestHost(event)}${event.path}';
}

/// #### Get the request protocol.
getRequestProtocol(H4Event event) {
  return event.node["value"]?.headers.value("x-forwarded-proto") ?? "http";
}

String? getRouteParam(H4Event event, {required String name}) {
  return event.params.containsKey(name) ? event.params[name] : null;
}

void handleCors(H4Event event, {String origin = "*", String methods = "*"}) {
  event.node["value"]!.response.headers
      .set(HttpHeaders.accessControlAllowOriginHeader, origin);

  event.node["value"]!.response.headers
      .set(HttpHeaders.accessControlAllowMethodsHeader, methods);
}

class FormData {
  final Map<String, List<String>> _data = {};

  void append(String name, dynamic value) {
    _data.putIfAbsent(name, () => []).add(value);
  }

  log() {
    print(_data);
  }

  dynamic get(String name) {
    final values = _data[name];
    return values?.isNotEmpty == true ? values!.first : null;
  }

  List<dynamic>? getAll(String name) {
    return _data[name];
  }
}

Future<FormData> handleMultipartFormdata(
    HttpRequest request, String boundary, FormData formData) async {
  final parts = await request
      .transform(StreamTransformer.castFrom(MimeMultipartTransformer(boundary)))
      .toList();

  for (var part in parts) {
    final headers = part.headers;
    final contentType = headers['content-type'];
    final contentDisposition = headers['content-disposition'];
    final nameMatch =
        RegExp(r'name="([^"]*)"').firstMatch(contentDisposition ?? '');
    final fieldName = nameMatch?.group(1);
    final filenameMatch =
        RegExp(r'filename="([^"]*)"').firstMatch(contentDisposition ?? '');
    final filename = filenameMatch?.group(1);

    if (fieldName != null) {
      if (contentType != null || filename != null) {
        // Handle all file data as bytes
        final bytes = await part.fold<dynamic>(
          [],
          (prev, element) => prev..addAll(element),
        );
        Map<String, dynamic> fieldData = {
          'data': bytes,
        };
        if (contentType != null) fieldData['contentType'] = contentType;
        if (filename != null) fieldData['filename'] = filename;
        formData.append(fieldName, fieldData.toString());
      } else {
        // Handle plain text data as string
        final content = await utf8.decoder.bind(part).join();
        formData.append(fieldName, content);
      }
    }
  }

  return formData;
}

Future<FormData> readFormData(dynamic event) async {
  final HttpRequest request = event.node["value"];
  final contentType = request.headers.contentType;
  var formData = FormData();

  if (contentType?.mimeType == 'multipart/form-data') {
    final boundary = contentType!.parameters['boundary'];
    if (boundary != null) {
      formData = await handleMultipartFormdata(request, boundary, formData);
    } else {
      throw Exception('Missing boundary in multipart/form-data');
    }
  } else if (contentType?.mimeType == 'application/x-www-form-urlencoded') {
    await _handleUrlEncodedFormData(request, formData);
  } else {
    throw Exception('Unsupported content type: ${contentType?.mimeType}');
  }

  return formData;
}

Future<void> _handleUrlEncodedFormData(
    HttpRequest request, FormData formData) async {
  final body = await utf8.decodeStream(request);
  final pairs = body.split('&');
  for (final pair in pairs) {
    final parts = pair.split('=');
    if (parts.length == 2) {
      final name = Uri.decodeComponent(parts[0]);
      final value = Uri.decodeComponent(parts[1]);
      formData.append(name, value);
    }
  }
}
