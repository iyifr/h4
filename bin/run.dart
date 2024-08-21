// import 'package:console/console.dart' as console;

import 'dart:io';
import 'dart:math';

import 'package:h4/create.dart';
import 'package:h4/src/logger.dart';
import 'package:h4/utils/get_header.dart';
import 'package:h4/utils/get_query.dart';
import 'package:h4/utils/read_request_body.dart';
import 'package:h4/utils/set_response_header.dart';

void main(List<String> arguments) async {
  var router = createRouter();

  var app = createApp(
    port: 5173,
    onRequest: (event) => logger.info('$event'),
  );

  app.use(router);

  router.post("/vamos/:id/**", (event) async {
    var body = await readRequestBody(event);
    var header = getHeader(event, HttpHeaders.userAgentHeader);
    var query = getQueryParams(event);
    setResponseHeader(event, HttpHeaders.contentTypeHeader,
        value: 'application/json');
    return [header, body, query, event.params];
  });

  router.get<Future<dynamic>>('/int', (event) async {
    try {
      Future<String> unreliableFunction() async {
        // Simulate some async operation
        await Future.delayed(Duration(seconds: 1));

        // Randomly succeed or fail
        if (Random().nextBool()) {
          return "Operation succeeded";
        } else {
          throw Exception("Random failure occurred");
        }
      }

      String result = await unreliableFunction();
      return result;
    } catch (e) {
      throw CreateError(message: "Error: $e");
    }
  });

  router.get("/vamos", (event) {
    throw CreateError(message: 'A grave error happened');
  });
}
