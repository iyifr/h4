import 'package:dio/dio.dart';

import 'package:h4/create.dart';
import 'package:h4/src/h4.dart';
import 'package:h4/src/router.dart';
import 'package:test/test.dart';

void main() {
  H4? app;
  H4Router router = createRouter();

  app = createApp(port: 5000);
  var config = BaseOptions(baseUrl: Uri.decodeFull("http://localhost:5000"));
  Dio dio = Dio(config);

  setUp(() {
    app?.use(router);
    router.get("/", (event) => "Hello World");
    router.get('/holla', (event) => 'Hi there');
  });

  tearDown(() async {
    print('Test ran.');
    await app?.close(force: true);
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

  // test('Handles named route', () async {
  //   final response = await dio.get('/holla');
  //   var foo = response.data;
  //   expect(foo, 'Hi there');
  //   expect(response.statusCode, 200);
  // });

  test('Handles param route', () async {
    router.get('/iyimide/:id', (event) => event.params["id"]);
    final response = await dio.get('/iyimide/12345');
    var foo = response.data;
    expect(foo, '12345');
  });

  test('Handles wildcard route', () async {
    router.get('/bigdawg/*', (event) => 'Fr');
    router.get('/fr/**', (event) => 'Fr Fr');
    final response = await dio.get('/bigdawg/2');
    final response2 = await dio.get('/fr/home/page');
    final response3 = await dio.get('/fr/home/page/foo/bar');

    expect(response.data, 'Fr');
    expect(response2.data, 'Fr Fr');
    expect(response3.data, 'Fr Fr');
  });

  // test('Handles different HTTP methods', () async {
  //   router.get('/hello', (event) => '${event.method} - hello');
  //   router.post('/hello', (event) => '${event.method} - hello');
  //   router.put('/hello', (event) => '${event.method} - hello');
  //   router.delete('/hello', (event) => '${event.method} - hello');
  //   router.patch('/hello', (event) => '${event.method} - hello');

  //   final response = await dio.get('/hello');
  //   final response2 = await dio.post('/hello');
  //   final response3 = await dio.put('/hello');
  //   final response4 = await dio.delete('/hello');
  //   final response5 = await dio.patch('/hello');

  //   expect(response.data, '${response.requestOptions.method} - hello');
  //   expect(response2.data, '${response2.requestOptions.method} - hello');
  //   expect(response3.data, '${response3.requestOptions.method} - hello');
  //   expect(response4.data, '${response4.requestOptions.method} - hello');
  //   expect(response5.data, '${response5.requestOptions.method} - hello');
  // });

  // test('Handles async handlers', () async {
  //   router.get('/async', (event) async => await Future.value(6700));

  //   final response = await dio.get('/async');
  //   expect(response.data, '6700');
  // });
}
