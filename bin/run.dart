// import 'package:console/console.dart' as console;

import 'package:h3/create.dart';

void main(List<String> arguments) async {
  var app = createApp();
  var router = createRouter();

  app.use(router);

  router.get("/", (event) => "Hello world");
  router.post("/", (event) => "HIII");
  router.get("/:id", (event) {
    print(event.params);
    return "Hi ${event.params?["id"]}";
  });

  router.get("/vamos/:studentId", (event) => "Response");
}
