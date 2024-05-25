// import 'package:console/console.dart' as console;

import 'package:h3/http-layer/h4.dart';
import 'package:h3/http-layer/index.dart';

void main(List<String> arguments) async {
  var router = H4Router((event) => "Hi");

  var app = createApp();
  app.use(router);

  router.post("/", (event) => "HIII");
  router.get("/:id", (event) {
    print(event.params);
    return "Hi ${event.params?["ïd"]}";
  });
}
