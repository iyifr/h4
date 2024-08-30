import 'package:h4/create.dart';
import 'package:h4/utils/req_utils.dart';
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

  app.use(router);

  router.get<Future<String>>("/", (event) async {
    // Still 'Ogunlepon'
    print(event.context["user"]);
    print(getQueryParams(event));
    var formdata = await readFormData(event);
    print(formdata.getAll('file'));
    return 'Hello world';
  });
}
