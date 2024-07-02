// import 'package:console/console.dart' as console;

import 'dart:io';

import 'package:h4/create.dart';
import 'package:h4/src/create_error.dart';
import 'package:h4/src/logger.dart';
import 'package:h4/utils/get_header.dart';
import 'package:h4/utils/get_query.dart';
import 'package:h4/utils/read_request_body.dart';
import 'package:h4/utils/set_response_header.dart';

void main(List<String> arguments) async {
  initLogger();

  var app = createApp(port: 4000, autoStart: false);

  await app.start().then((h4) => logger.warning(h4?.port));

  var router = createRouter();

  app.use(router);

  router.get('/', (event) {
    return null;
  });

  router.get("/hi/:id", (event) {
    throw Exception('Yo');
    // return 'Hey ${event.params["id"]}';
  });

  router.post("/vamos", (event) async {
    var body = await readRequestBody(event);
    var header = getHeader(event, HttpHeaders.viaHeader);
    var query = getQueryParams(event);
    setResponseHeader(event, HttpHeaders.contentTypeHeader,
        value: 'application/json');
    return [header, body, query];
  });

  router.get<Future<int>>('/int', (event) async {
    await Future.delayed(Duration(seconds: 1));
    var res = await Future.value(23994);
    return res;
  });

  router.get("/vamos", (event) {
    throw CreateError(message: 'A grave error happened', errorCode: 404);
  });
}
