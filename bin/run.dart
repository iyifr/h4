// import 'package:console/console.dart' as console;

import 'package:h3/create.dart';

void main(List<String> arguments) async {
  var app = createApp();
  var router = createRouter();

  app.use(router);
  // router.get("/", (event) => "<p>Hello world my name is destroyer</p>");
  // router.get(
  //     "/:id/hi/bye/shy", (event) => "<p>Hiiiiii ${event.params?["id"]}</p>");

  router.get("/*", (event) => "welcome");
  router.get("/25/**", (event) => "welcome hooooommeee");
}
