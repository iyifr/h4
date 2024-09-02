// import 'package:console/console.dart' as console;

import 'dart:io';
import 'dart:math';

import 'package:h4/create.dart';
import 'package:h4/utils/get_header.dart';
import 'package:h4/utils/get_query.dart';
import 'package:h4/utils/read_request_body.dart';

void main(List<String> arguments) async {
  var app = createApp(
    port: 5173,
    onRequest: (event) => {},
    afterResponse: (event) => {},
  );

  var router = createRouter();
  app.use(router);

  router.post("/vamos/:id/**", (event) async {
    var body = await readRequestBody(event);
    print(body["map"]);
    var header = getHeader(event, HttpHeaders.userAgentHeader);
    var query = getQueryParams(event);
    return [header, body, query, event.params];
  });

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

  router.get<Future<dynamic>>('/int', (H4Event event) async {
    try {
      String result = await unreliableFunction();
      return result;
    } catch (e) {
      throw CreateError(
          message: "Error occurred while proccessing: $e", errorCode: 500);
    }
  });

  router.get("/vamos", (event) {
    throw CreateError(message: 'A grave error happened');
  });
}
