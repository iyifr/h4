// import 'package:console/console.dart' as console;

import 'package:h4/create.dart';
import 'package:h4/src/create_error.dart';

void main(List<String> arguments) async {
  var app = createApp(port: 4000, autoStart: false);

  await app.start().then((h4) => print(h4?.port));

  var router = createRouter();

  app.use(router);

  app.onRequest((event) {
    print(event.path);
  });

  app.onError(
      (error, stack, event) => print('Error occured at ${event?.path}'));

  router.get<bool>("/25/**", (event) => true);
  router.get("/:id", (event) {
    print('param: ${event.params["id"]}');
    return 'Hey';
  });

  router.post("/vamos", (event) async {
    await Future.delayed(Duration(milliseconds: 100));
    return "HELLLO MANYANA";
  });

  router.get('/error', (event) async {
    try {
      await Future.delayed(Duration(seconds: 1));
      throw Exception("Wahala");
    } catch (error, stackTrace) {
      print('Error: $error');
      print('Stacktrace: $stackTrace');
      rethrow;
    }
  });

  router.get("/vamos", (event) {
    throw CreateError(message: 'A grave error happened', errorCode: 404);
  });
}
