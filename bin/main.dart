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
  var apiRouter = createRouter();

  app.use(router, basePath: '/');
  app.use(apiRouter, basePath: '/api');

  router.get("/", (event) {
    return 'Hello from /';
  });

  apiRouter.get("/", (event) {
    return 'Hi from /api';
  });
}
