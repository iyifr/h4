import 'package:h4/create.dart';

void main() async {
  var app = createApp(
    port: 3000,
    onRequest: (event) {
      // PER REQUEST local state😻
      event.context["user"] = 'Ogunlepon';
      print(getRequestUrl(event));
    },
    afterResponse: (event) => {print(event.eventResponse)},
  );

  var router = createRouter();

  app.use(router, basePath: '/');
  
  router.get('/', (event) {
    return {'hello': 'world'};
  });

  router.post('/', (event) {
    return {'hello': 'twurkio'};
  });
}
