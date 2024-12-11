import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:h4/create.dart';
import 'package:h4/src/logger.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

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

  @override
  String toString() {
    return _data.toString();
  }

  dynamic get(String name) {
    final values = _data[name];
    var result = values?.isNotEmpty == true ? values!.first : null;
    return result;
  }

  List<dynamic>? getAll(String name) {
    return _data[name];
  }
}

Future<FormData> readFormData(dynamic event) async {
  final HttpRequest request = event.node["value"];
  final contentType = request.headers.contentType;
  var formData = FormData();

  if (contentType?.mimeType == null) {
    logger.warning("NO formdata fields in request body");
    throw CreateError(message: "No formdata fields found");
  }

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

Future<FormData> handleMultipartFormdata(
    HttpRequest request, String boundary, FormData formData) async {
  final mimeTransformer = MimeMultipartTransformer(boundary);
  final parts = request.cast<List<int>>().transform(mimeTransformer);

  await for (final part in parts) {
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
        // Stream file to temporary storage
        final fileInfo = await _streamToStorage(part, filename);

        Map<String, dynamic> fieldData = {
          'path': fileInfo['path'],
          'mimeType': contentType,
          'originalname': filename,
          'fieldName': fieldName,
          'size': fileInfo['size'],
          'tempFilename': fileInfo['tempFilename'],
        };
        formData.append(fieldName, json.encode(fieldData));
      } else {
        // Handle plain text data as string
        final content = await utf8.decoder.bind(part).join();
        formData.append(fieldName, content);
      }
    }
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

String detectEncoding(Uint8List bytes) {
  if (bytes.length < 4) return 'unknown';

  // Check UTF-8 BOM
  if (bytes.length >= 3 &&
      bytes[0] == 0xEF &&
      bytes[1] == 0xBB &&
      bytes[2] == 0xBF) {
    return 'UTF-8';
  }

  // Check UTF-16 LE BOM
  if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xFE) {
    return 'UTF-16LE';
  }

  // Check UTF-16 BE BOM
  if (bytes.length >= 2 && bytes[0] == 0xFE && bytes[1] == 0xFF) {
    return 'UTF-16BE';
  }

  // If no BOM is found, assume UTF-8
  return 'UTF-8';
}

Future<Map<String, dynamic>> _streamToStorage(
    Stream<List<int>> dataStream, String? originalFilename) async {
  // Create unique filename to avoid collisions
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final randomId =
      DateTime.now().microsecondsSinceEpoch.toString().substring(8);
  final safeFilename =
      originalFilename?.replaceAll(RegExp(r'[^a-zA-Z0-9.-]'), '_') ?? 'unnamed';
  final filename = '${timestamp}_${randomId}_$safeFilename';

  // Get system temp directory
  final tempDir = Directory.systemTemp;
  final filePath = path.join(tempDir.path, filename);
  final file = File(filePath);

  // Stream metrics
  var totalSize = 0;
  const maxSize = 500 * 1024 * 1024; // 10MB limit, adjust as needed

  try {
    final sink = file.openWrite();
    await for (var chunk in dataStream) {
      totalSize += chunk.length;
      if (totalSize > maxSize) {
        await sink.close();
        await file.delete();
        throw CreateError(message: 'File size exceeds maximum allowed size');
      }
      sink.add(chunk);
    }
    await sink.close();

    return {
      'path': filePath,
      'size': totalSize,
      'originalname': originalFilename,
      'tempFilename': filename,
    };
  } catch (e) {
    // Clean up on error
    if (await file.exists()) {
      await file.delete();
    }
    throw CreateError(message: 'Failed to save file: ${e.toString()}');
  }
}
