// import 'package:console/console.dart' as console;

import 'package:h4/create.dart';
import 'package:h4/src/create_error.dart';
import 'package:h4/src/logger.dart';
import 'package:h4/utils/read_request_body.dart';

void main(List<String> arguments) async {
  initLogger();

  var app = createApp(port: 4000, autoStart: false);

  await app.start().then((h4) => logger.warning(h4?.port));

  var router = createRouter();

  app.use(router);

  app.onRequest((event) {
    print(event.path);
  });

  app.onError((error, stack, event) =>
      print('Error occured at ${event?.path}\n$error'));

  router.get<bool>("/25/**", (event) => true);
  
  router.get("/:id", (event) {
    print('param: ${event.params["id"]}');
    return 'Hey';
  });

  router.post("/vamos", (event) async {
    var body = await readRequestBody(event);
    return body;
  });

  router.get('/error', (event) async {
    await Future.delayed(Duration(seconds: 1));
    throw Exception("Wahala");
  });

  router.get("/vamos", (event) {
    throw CreateError(message: 'A grave error happened', errorCode: 404);
  });
}
