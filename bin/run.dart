// import 'package:console/console.dart' as console;

import 'package:h4/create.dart';
import 'package:h4/utils/create_error.dart';

void main(List<String> arguments) {
  var app = createApp();
  var router = createRouter();

  app.use(router);

  app.onRequest((event) {
    print(event.path);
    print(event.method);
    print(event.statusMessage);
  });

  app.onError((e, s) {
    print("$e");
  });

  router.get("/25/**", (event) => throw Exception("WtF"));

  router.post("/vamos", (event) async {
    await Future.delayed(Duration(milliseconds: 200));
    return "HELLLO MANYANA";
  });
}
