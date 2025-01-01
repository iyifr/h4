import 'dart:math';

import 'package:h4/create.dart';

void main(List<String> arguments) async {
  var app = createApp(
    port: 5173,
  );

  var router = createRouter();
  app.use(router);

  router.post("/vamos/:id/**", (event) async {
    var body = await readRequestBody(event);
    var header = getRequestUrl(event);
    return [header, body];
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

  router.get('/hi', (event) {
    return [13];
  });
}
