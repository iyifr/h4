import 'package:h4/create.dart';
import 'package:h4/utils/get_query.dart';

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

  app.use(router, basePath: '/');

  router.get("/", (event) async {
    return 'Hello';
  });
}
