import 'package:h4/create.dart';

void main() async {
  var app = createApp(
    port: 5173,
    onRequest: (event) {
      // PER Request local state
      event.context["user"] = 'Baba o ';
      print((event.context));
    },
    afterResponse: (event) => {print('handled')},
  );

  var router = createRouter();

  app.use(router);

  router.get<String>("/", (event) {
    return 'Hello world';
  });

  router.get("/hi", (event) {
    throw CreateError(message: "HAHA");
  });
}
