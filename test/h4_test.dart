import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:h4/create.dart';
import 'package:h4/src/h4.dart';
import 'package:h4/src/router.dart';
import 'package:h4/utils/body_utils.dart';
import 'package:h4/utils/request_utils.dart';
import 'package:test/test.dart';

void main() {
  H4? app;
  H4Router router = createRouter();

  var config = BaseOptions(
    baseUrl: Uri.decodeFull("http://localhost:8000"),
  );
  Dio dio = Dio(config);
  app = createApp(port: 8000);
  app.use(router);

  tearDownAll(() async {
    await app?.close();
  });

  test('Initializes server correctly', () async {
    try {
      router.get("/", (event) => "Hello World");
      final response = await dio.get('/');
      expect(response.statusCode, 200);
    } catch (e) {
      print(e);
    }
  });

  test('Handles named route', () async {
    router.get("/holla", (event) => "YEAH");
    final response = await dio.get('/holla');
    var foo = response.data;
    expect(foo, 'YEAH');
    expect(response.statusCode, 200);
  });

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

  test('Handles different HTTP methods', () async {
    router.get('/hello', (event) => '${event.method} - hello');
    router.post('/hello', (event) => '${event.method} - hello');
    router.put('/hello', (event) => '${event.method} - hello');
    router.delete('/hello', (event) => '${event.method} - hello');
    router.patch('/hello', (event) => '${event.method} - hello');

    final response = await dio.get('/hello');
    final response2 = await dio.post('/hello');
    final response3 = await dio.put('/hello');
    final response4 = await dio.delete('/hello');
    final response5 = await dio.patch('/hello');

    expect(response.data, '${response.requestOptions.method} - hello');
    expect(response2.data, '${response2.requestOptions.method} - hello');
    expect(response3.data, '${response3.requestOptions.method} - hello');
    expect(response4.data, '${response4.requestOptions.method} - hello');
    expect(response5.data, '${response5.requestOptions.method} - hello');
  });

  test('Handles async handlers', () async {
    router.get('/async', (event) async => await Future.value(6700));

    final response = await dio.get('/async');
    expect(response.data, '6700');
  });

  test('Handles single param routes', () async {
    router.get('/user/:id', (event) => event.params['id']);

    final response = await dio.get('/user/xyz_abc_123');
    expect(response.data, 'xyz_abc_123');
  });

  test('Handles match-all wildcard routes', () async {
    router.get('/user/**', (event) => "Welcome to H4!");

    final req1 = dio.get('/user/fun');
    final req2 = dio.get('/user/fun/me');
    final req3 = dio.get('/user/fun/me/you');

    final responses = await Future.wait([req1, req2, req3]);

    for (final response in responses) {
      expect(response.data, "Welcome to H4!");
    }
  });

  test('Handles paramaterized match-all requests', () async {
    router.get('/donut/:id/**', (event) => "Welcome to H4!");

    final req1 = dio.get('/donut/user/fun');
    final req2 = dio.get('/donut/user/fun/me');
    final req3 = dio.get('/donut/user/fun/me/you');

    final responses = await Future.wait([req1, req2, req3]);

    for (final response in responses) {
      expect(response.data, "Welcome to H4!");
    }
  });

  test('Reads the request body', () async {
    router.post('/body', (event) async {
      var body = await readRequestBody(event);
      return body;
    });

    final req = await dio.post('/body',
        data: {"hi": 12},
        options: Options(
          headers: {'content-type': 'application/json'},
        ));
    expect(jsonDecode(req.data), {"hi": 12});
  });

  test('Correctly parses query parameters', () async {
    router.get('/body', (event) async {
      return await getQueryParams(event);
    });

    final response = await dio.get('/body?query=iyimide&answer=laboss');

    expect(jsonDecode(response.data), {"query": "iyimide", "answer": "laboss"});
  });

  test('Regex pattern for routes', () {
    final regex = RegExp(
      r'^(?:'
      r'/'
      r'|/(?:[\p{L}\p{N}_-]+(?:/[\p{L}\p{N}_-]+)*/?)'
      r'|/(?:[\p{L}\p{N}_-]+/)*(?::[\p{L}\p{N}_]+)(?:/[\p{L}\p{N}_-]+)*(?:/(?:[\p{L}\p{N}_-]+/)*(?::[\p{L}\p{N}_]+)(?:/[\p{L}\p{N}_-]+)*)*/?'
      r'|/[\p{L}\p{N}_-]+/:[^/]+/\*\*'
      r'|/[\p{L}\p{N}_-]+/\*\*'
      r'|/[\p{L}\p{N}_-]+/\*'
      r'| '
      r'|\*'
      r')$',
      unicode: true,
    );

    final testCases = [
      '/:id/base/:studentId',
      '/user/:id/posts/:postId',
      '/api/:version/users/:userId/profile',
      '/:id/:uuid/:hqhaId',
      '/user/:id/:postId',
      '/user/123',
      '/user/:id',
      '/user/:id/posts',
      '/',
      ' ',
      '*',
    ];

    for (final test in testCases) {
      expect(regex.hasMatch(test), true);
    }
  });
}
