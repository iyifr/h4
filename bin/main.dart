import 'package:console/console.dart' as console;
import 'package:h4/create.dart';

void main() async {
  var app = createApp(
    port: 5173,
    onRequest: (event) => {},
    onError: (error, stacktrace, event) => {},
    afterResponse: (event) => {},
  );

  var router = createRouter();
  app.use(router);

  router.get("/", (event) {
    return 'Hello world';
  });
}
