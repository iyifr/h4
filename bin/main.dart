import 'dart:io';

import 'package:h4/create.dart';
import 'package:h4/utils/req_utils.dart';
import 'package:h4/utils/response_utils.dart';

void main() async {
  var app = createApp(
    port: 5173,
    onRequest: (event) {
      // PER REQUEST local state😻
      event.context["user"] = 'Ogunlepon';
      print(getRequestUrl(event));

      setResponseHeader(event,
          header: HttpHeaders.contentTypeHeader,
          value: 'text/html; charset=utf-8');
    },
    afterResponse: (event) => {},
  );

  var router = createRouter();
  var apiRouter = createRouter();

  app.use(router, basePath: '/');
  app.use(apiRouter, basePath: '/api');

  router.get("/vamos/:id/base/:studentId", (event) {
    return event.params;
  });

  apiRouter.get("/signup", (event) async {
    var formData = await readFormData(event);

    var username = formData.get('username');
    var password = formData.get('password');

    print(getRequestIp(event));

    // userService.signup(username, password);
    event.statusCode = 201;

    return 'Hi from /api with $username, $password';
  });
}
