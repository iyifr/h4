// import 'package:console/console.dart' as console;

import 'package:h3/create.dart';

void main(List<String> arguments) async {
  var app = createApp();
  var router = createRouter();

  app.use(router);

  app.onRequest((event) {
    print(event.path);
  });

  app.onError((e, s) {
    print("UH OHHHHH $e");
  });

  router.get("/*", (event) {
    throw Exception("Wahala");
  });
  router.get("/25/**", (event) => "welcome hooooommeee");
}
