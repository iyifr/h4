import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:h4/create.dart';
import 'package:h4/src/logger.dart';
import 'package:h4/utils/formdata.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

export 'package:h4/utils/req_utils.dart' hide detectEncoding;

String? getRequestIp(H4Event event) {
  var ip = event.node["value"]?.headers
      .value("X-Forwarded-For")
      ?.split(',')[0]
      .trim();

  ip ??= event.node["value"]?.headers.value("X-Real-IP")?.trim();
  ip ??= event.node["value"]?.headers.value("CF-Connecting-IP")?.trim();
  ip ??= event.node["value"]?.headers.value("True-Client-IP")?.trim();

  ip ??= event.node["value"]?.connectionInfo?.remoteAddress.address;

  return ip;
}

/// **Get incoming request host**
///
/// Extracts the host header from the incoming HTTP request.
/// This typically returns the domain name or IP address (and optionally port)
/// that the client used to make the request.
///
/// ```dart
/// router.get("/home", (event) {
///   String? host = getRequestHost(event); // e.g. "example.com" or "localhost:8080"
/// });
/// ```
///
/// Returns null if the host header is not present.
String? getRequestHost(H4Event event) {
  return event.node["value"]?.headers.value(HttpHeaders.hostHeader);
}

/// #### Get the entire incoming URL.
///
/// ```dart
/// router.get("/home", (event) => {
///   var url = getRequestUrl(event) // https://app-client-url.com/products
/// })
/// ```
String? getRequestUrl(H4Event event) {
  return '${getRequestProtocol(event)}://${getRequestHost(event)}${event.path}';
}

/// **Get the request protocol**
///
/// Determines whether the request was made over HTTP or HTTPS.
/// First checks the 'x-forwarded-proto' header (commonly set by proxies),
/// then falls back to checking if the connection itself is secure.
///
/// ```dart
/// router.get("/home", (event) {
///   String protocol = getRequestProtocol(event); // "http" or "https"
///   // Use protocol in constructing URLs or making security decisions
/// });
/// ```
///
/// Returns "https" for secure connections, "http" otherwise.
String? getRequestProtocol(H4Event event) {
  // Check forwarded protocol header first (set by proxies/load balancers)
  final forwardedProto =
      event.node["value"]?.headers.value("x-forwarded-proto");
  if (forwardedProto != null) {
    return forwardedProto.toLowerCase();
  }

  // Fall back to checking if the connection itself is secure
  final isSecure = event.node["value"]?.connectionInfo?.localPort == 443 ||
      (event.node["value"]?.headers.value('x-forwarded-ssl') == 'on') ||
      (event.node["value"]?.headers.value('x-forwarded-scheme') == 'https');
  return isSecure ? "https" : "http";
}

/// Gets a route parameter value by name from the event.
///
/// ```dart
/// // For a route defined as: '/users/:id'
/// router.get('/users/:id', (event) {
///   // Access the id parameter
///   String? userId = getRouteParam(event, name: 'id');
///
///   if (userId != null) {
///     return {'userId': userId};
///   }
///   return {'error': 'No user id provided'};
/// });
/// ```
///
/// Returns null if the parameter is not found.
///
/// Parameters:
/// - event: The H4Event containing route parameters
/// - name: The name of the route parameter to retrieve
String? getRouteParam(H4Event event, {required String name}) {
  return event.params.containsKey(name) ? event.params[name] : null;
}

/// Handles Cross-Origin Resource Sharing (CORS) headers for HTTP requests.
///
/// This function sets the appropriate CORS headers on the response to enable
/// cross-origin requests. It supports configuring allowed origins, methods,
/// headers, credentials, and cache duration.
///
/// Example usage:
///
/// ```dart
/// // Basic usage with default settings
/// router.get('/api', (event) {
///   handleCors(event);
///   return {'message': 'API response'};
/// });
///
/// // Set CORS headers for every request
/// var app = createApp(
/// onRequest: (event) {
///   handleCors(event,
///     origin: 'https://myapp.com',
///     methods: 'GET, POST',
///     headers: 'Content-Type, Authorization',
///     credentials: true,
///     maxAge: 3600
///    )
///  }
/// )
///
/// // Custom CORS configuration
/// router.post('/api/auth', (event) {
///   handleCors(
///     event,
///     origin: 'https://myapp.com',
///     methods: 'GET, POST',
///     headers: 'Content-Type, Authorization',
///     credentials: true,
///     maxAge: 3600
///   );
///   return {'status': 'authenticated'};
/// });
/// ```
/// Parameters:
/// - event: The H4Event containing the request and response
/// - origin: Allowed origin(s). Defaults to "*" for all origins
/// - methods: Comma-separated list of allowed HTTP methods
/// - headers: Comma-separated list of allowed request headers
/// - credentials: Whether to allow credentials (cookies, auth headers)
/// - maxAge: How long browsers should cache the preflight response (in seconds)
void handleCors(
  H4Event event, {
  String origin = "*",
  String methods = "GET, POST, PUT, DELETE, OPTIONS, HEAD, PATCH",
  String headers = "Content-Type, Authorization, X-Requested-With",
  bool credentials = false,
  int maxAge = 86400, // 24 hours
}) {
  final response = event.node["value"]!.response;

  // Set basic CORS headers
  response.headers.set(HttpHeaders.accessControlAllowOriginHeader, origin);
  response.headers.set(HttpHeaders.accessControlAllowMethodsHeader, methods);
  response.headers.set(HttpHeaders.accessControlAllowHeadersHeader, headers);

  if (credentials) {
    response.headers
        .set(HttpHeaders.accessControlAllowCredentialsHeader, 'true');

    // When credentials are allowed, origin cannot be "*"
    if (origin == "*") {
      // Use the requesting origin if available
      final requestOrigin = event.node["value"]?.headers.value('Origin');
      if (requestOrigin != null) {
        response.headers
            .set(HttpHeaders.accessControlAllowOriginHeader, requestOrigin);
      }
    }
  }

  response.headers
      .set(HttpHeaders.accessControlMaxAgeHeader, maxAge.toString());

  if (event.node["value"]?.method == 'OPTIONS') {
    response.statusCode = HttpStatus.noContent; // 204
    response.headers.set(HttpHeaders.contentLengthHeader, '0');
  }
}

Future<FormData> readFormData(dynamic event) async {
  final HttpRequest request = event.node["value"];
  final contentType = request.headers.contentType;
  final boundary = contentType?.parameters['boundary'];
  var formData = FormData();

  if (contentType == null) {
    throw CreateError(message: "Content type header not set");
  }

  if (contentType.mimeType.isEmpty) {
    logger.warning("NO formdata fields in request body");
    throw CreateError(message: "No formdata fields found");
  }

  bool hasBoundary = boundary != null;

  if (contentType.mimeType == 'multipart/form-data') {
    return hasBoundary
        ? await _handleMultipartFormdata(request, boundary, formData)
        : throw CreateError(message: "No boundary found");
  }

  if (contentType.mimeType == 'application/x-www-form-urlencoded') {
    await _handleUrlEncodedFormData(request, formData);
    return formData;
  }

  throw Exception('Unsupported content type: ${contentType.mimeType}');
}

Future<FormData> _handleMultipartFormdata(
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
        final fileInfo = await _streamToStorage(part,
            originalFilename: filename, customFilePath: null);

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

/// Reads file(s) from a multipart/form-data request for a specific field name.
///
/// Example usage:
/// ```dart
/// final files = await readFiles(event,
///   fieldName: 'photos',
///   hashFileName: true,
///   maxFileSize: 5 // 5MB limit
/// );
/// ```
///
/// Parameters:
/// - [fieldName]: The form field name containing the file(s)
/// - [customFilePath]: Optional custom path to save uploaded files
/// - [hashFileName]: If true, generates a unique hashed filename (default: false)
/// - [maxFileSize]: Maximum file size in MB (default: 10MB)
///
/// Returns a List of file information maps containing:
/// ```dart
/// {
///   'path': String,         // File path on disk
///   'mimeType': String,     // File content type
///   'originalname': String, // Original file name
///   'fieldName': String,    // Form field name
///   'size': int,           // File size in bytes
///   'filename': String // current file name
/// }
/// ```
///
/// Returns null if no files are found for the specified fieldName.
///
/// Throws [CreateError] if:
/// - Request is not multipart/form-data
/// - Boundary is missing in content type
/// - File size exceeds maxFileSize
/// - File upload fails
Future<List<Map<String, dynamic>>?> readFiles(H4Event event,
    {required String fieldName,
    String? customFilePath,
    bool hashFileName = false,
    int maxFileSize = 10}) async {
  final HttpRequest request = event.node["value"]!;
  final contentType = request.headers.contentType;

  if (contentType?.mimeType != 'multipart/form-data') {
    throw CreateError(
        message: 'Files can only be uploaded using multipart/form-data');
  }

  final boundary = contentType!.parameters['boundary'];
  if (boundary == null) {
    throw CreateError(message: 'Missing boundary in multipart/form-data');
  }

  final mimeTransformer = MimeMultipartTransformer(boundary);
  final parts = request.cast<List<int>>().transform(mimeTransformer);
  List<Map<String, dynamic>> files = [];

  try {
    await for (final part in parts) {
      final headers = part.headers;
      final contentType = headers['content-type'];
      final contentDisposition = headers['content-disposition'];
      final nameMatch =
          RegExp(r'name="([^"]*)"').firstMatch(contentDisposition ?? '');
      final currentFieldName = nameMatch?.group(1);
      final filenameMatch =
          RegExp(r'filename="([^"]*)"').firstMatch(contentDisposition ?? '');
      final filename = filenameMatch?.group(1);

      // Only process if it matches the requested fieldName and has a filename
      if (currentFieldName == fieldName && filename != null) {
        final fileInfo = await _streamToStorage(part,
            originalFilename: filename,
            customFilePath: customFilePath,
            hashFileName: hashFileName,
            maxFileSize: maxFileSize);
        files.add({
          'path': fileInfo['path'],
          'mimeType': contentType,
          'originalname': filename,
          'fieldName': fieldName,
          'size': fileInfo['size'],
          'filename': fileInfo['filename'],
        });
      }
    }
    return files.isEmpty ? null : files;
  } catch (e) {
    throw CreateError(
        message: 'Failed to read files from formdata: ${e.toString()}');
  }
}

Future<Map<String, dynamic>> _streamToStorage(Stream<List<int>> dataStream,
    {String? originalFilename,
    String? customFilePath,
    bool hashFileName = false,
    int maxFileSize = 10}) async {
  String? filename = originalFilename;

  if (hashFileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomId =
        DateTime.now().microsecondsSinceEpoch.toString().substring(8);
    final safeFilename =
        originalFilename?.replaceAll(RegExp(r'[^a-zA-Z0-9.-]'), '_') ??
            'unnamed';
    filename = '$timestamp$randomId$safeFilename';
  }

  // Use custom path if provided, otherwise use system temp directory
  final String filePath;
  if (customFilePath != null) {
    // Create directory if it doesn't exist
    final directory = Directory(customFilePath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    filePath = path.join(customFilePath, filename);
  } else {
    final tempDir = Directory.systemTemp;
    filePath = path.join(tempDir.path, filename);
  }

  final file = File(filePath);

  // Stream metrics
  var totalSize = 0;
  final maxSize = maxFileSize * 1024 * 1024; // 10MB limit, adjust as needed

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
      'filename': filename,
    };
  } catch (e) {
    // Clean up on error
    if (await file.exists()) {
      await file.delete();
    }
    throw CreateError(message: 'Failed to save file on disk: ${e.toString()}');
  }
}
