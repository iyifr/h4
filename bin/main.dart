import 'package:h4/create.dart';

void main() async {
  var app = createApp(
    port: 5173,
    onRequest: (event) {
      // PER REQUEST local state😻
      event.context["user"] = 'Ogunlepon';
      print(getRequestUrl(event));
    },
    afterResponse: (event) => {},
  );

  var router = createRouter();
  var apiRouter = createRouter();

  app.use(router, basePath: '/');
  app.use(apiRouter, basePath: '/api');

  router.get("/vamos/:id/base/:studentId", (event) {
    return getRouteParam(event, name: "studentId");
  });

  apiRouter.get("/signup", (event) async {
    var formData = await readFormData(event);

    var username = formData.get('username');
    var password = formData.get('password');

    return 'Hi from /api with $username, $password';
  });

  apiRouter.post("/upload", (event) async {
    var files = await readFiles(event, fieldName: 'file', customFilePath: 'uploads');
    setResponseHeader(event, header: 'Content-Type', value: 'application/json');
    return files;
  });
}
