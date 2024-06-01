// import 'package:console/console.dart' as console;

import 'package:h4/create.dart';
import 'package:h4/src/create_error.dart';
import 'package:h4/src/logger.dart';

void main(List<String> arguments) async {
  var app = createApp();
  print("App is running on ${app.port}");
  var router = createRouter();

  app.use(router);

  app.onRequest((event) {
    print(event.path);
  });

  app.onError(
      (error, stack, event) => print('Error occured at ${event?.path}'));

  router.get<bool>("/25/**", (event) => true);
  router.get("/", (event) => throw ("HSHAHAHAH"));

  router.post("/vamos", (event) async {
    await Future.delayed(Duration(milliseconds: 200));
    return "HELLLO MANYANA";
  });

  router.get("/vamos", (event) {
    throw CreateError(message: 'Error occured', errorCode: 404);
  });
}
