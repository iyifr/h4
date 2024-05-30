import 'dart:convert';
import 'dart:io';

import 'package:h4/src/event.dart';

Future<dynamic> readBody(HttpRequest request) async {
  var rawBody = await request.toList();

  if (rawBody.isNotEmpty) {
    var string = '';

    for (int i = 0; i < rawBody.length; i++) {
      string += utf8.decode(rawBody[i]); // Outputs each character of the string
    }
    return string;
  }

  return null;
}

Future<dynamic> readEventBody(H4Event event) async {
  var request = event.node["value"];

  if (request == null) {
    return;
  }

  final eventBody = await readBody(request);
  return eventBody;
}
