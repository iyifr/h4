import 'dart:convert';
import 'dart:io';

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
