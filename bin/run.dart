// import 'package:console/console.dart' as console;

import 'dart:io';

import 'package:h4/create.dart';
import 'package:h4/utils/get_header.dart';
import 'package:h4/utils/get_query.dart';
import 'package:h4/utils/read_request_body.dart';
import 'package:h4/utils/set_response_header.dart';

Stream<String> countStream(int max) async* {
  for (int i = 1; i <= max; i++) {
    // Yield each value asynchronously
    await Future.delayed(Duration(seconds: 3));
    yield '<li>hi $i</li>';
  }
}

void main(List<String> arguments) async {
  var app = createApp(port: 5173);

  var router = createRouter();

  app.use(router);

  // router.get<bool>('/', (event) {
  //   return true;
  // });

  router.get<Stream<String>>('/', (event) {
    setResponseHeader(event, HttpHeaders.contentTypeHeader,
        value: 'text/event-stream');

    setResponseHeader(event, HttpHeaders.cacheControlHeader,
        value:
            "private, no-cache, no-store, no-transform, must-revalidate, max-age=0");

    setResponseHeader(event, HttpHeaders.transferEncodingHeader,
        value: 'chunked');

    setResponseHeader(event, "x-accel-buffering", value: "no");

    setResponseHeader(event, 'connection', value: 'keep-alive');

    print(event.node["value"]?.response.headers);

    return countStream(8);
  });

  router.post("/vamos/:id/**", (event) async {
    var body = await readRequestBody(event);
    var header = getHeader(event, HttpHeaders.userAgentHeader);
    var query = getQueryParams(event);
    setResponseHeader(event, HttpHeaders.contentTypeHeader,
        value: 'application/json');
    return [header, body, query, event.params];
  });

  router.get<Future<dynamic>>('/int', (event) async {
    return Future.error(Exception('Hula ballo'));
  });

  router.get("/vamos", (event) {
    throw CreateError(message: 'A grave error happened');
  });
}
