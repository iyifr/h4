// import 'package:console/console.dart' as console;

import 'package:h3/create.dart';

void main(List<String> arguments) async {
  var app = createApp();
  var router = createRouter();

  app.use(router);
  router.get("users/:id/database", (event) => []);
}
