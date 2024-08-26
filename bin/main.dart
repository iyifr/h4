import 'package:h4/create.dart';

void main() async {
  var app = createApp(
    port: 5173,
    onRequest: (event) {
      // PER REQUEST local state😻
      event.context["user"] = 'Ogunlepon';
    },
    afterResponse: (event) => {},
  );

  var router = createRouter();

  app.use(router);

  router.get<String>("/", (event) {
    // Still 'Ogunlepon'
    print(event.context["user"]);
    return 'Hello world';
  });
}
