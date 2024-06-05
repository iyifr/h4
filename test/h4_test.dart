import 'package:dio/dio.dart';

import 'package:h4/create.dart';
import 'package:h4/src/h4.dart';
import 'package:h4/src/router.dart';
import 'package:test/test.dart';

void main() {
  H4? app;
  H4Router router = createRouter();

  var config = BaseOptions(baseUrl: Uri.decodeFull("http://localhost:3000"));
  Dio dio = Dio(config);

  setUp(() {
    app = createApp();
    app?.start();
    app?.use(router);
    router.get("/", (event) => "Hello World");
  });

  tearDown(() async {
    await app?.close();
  });

  test('Initializes server correctly', () async {
    Future<bool> isServerRunning() async {
      try {
        final response = await dio.get('/');
        return response.statusCode == 200;
      } catch (e) {
        print(e);
        // Handle any errors that occur during the request
        return false;
      }
    }

    expect(await isServerRunning(), true);
  });

  test('Handles named route', () async {
    router.get('/holla', (event) => 'Hi there');
    final response = await dio.get('/holla');
    var foo = response.data;
    expect(foo, 'Hi there');
    expect(response.statusCode, 200);
  });
}
