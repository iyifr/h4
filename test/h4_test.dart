import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/src/form_data.dart' as dio_form_data;
import 'package:h4/create.dart';
import 'package:h4/src/router.dart';
import 'package:h4/utils/request_utils.dart';
import 'package:test/test.dart';
import 'package:h4/src/h4.dart';
import 'package:h4/utils/formdata.dart' as h4_formdata;

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
    print("Server closed");
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
    expect(req.data, {"hi": 12});
  });

  test('Correctly parses query parameters', () async {
    router.get('/body', (event) async {
      return await getQueryParams(event);
    });

    final response = await dio.get('/body?query=iyimide&answer=laboss');

    expect(response.data, {"query": "iyimide", "answer": "laboss"});
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

  test('Reads files from formdata', () async {
    router.post('/upload', (event) async {
      var files =
          await readFiles(event, fieldName: 'file', customFilePath: 'uploads');
      return files;
    });

    final formData = dio_form_data.FormData.fromMap({
      'file':
          await MultipartFile.fromFile('assets/test.txt', filename: 'test.txt'),
    });

    final response = await dio.post('/upload',
        data: formData,
        options: Options(
          headers: {'content-type': 'multipart/form-data'},
        ));

    var data = response.data;

    expect(data, isA<List>());
    expect(data[0]['originalname'], 'test.txt');
    expect(data[0]['fieldName'], 'file');
    expect(data[0]['mimeType'], 'application/octet-stream');
    expect(data[0]['path'], contains('uploads'));
    expect(data[0]['size'], equals(17));
  });

  tearDown(() async {
    // Clean up uploaded files and folders after each test
    final uploadDir = Directory('uploads');
    if (await uploadDir.exists()) {
      await uploadDir.delete(recursive: true);
    }
  });

  test('Reads normal formdata objects', () async {
    router.post('/formdata', (event) async {
      var formData = await readFormData(event);
      return {
        'name': formData.get('name'),
        'age': formData.get('age'),
        'hobbies': formData.getAll('hobbies'),
        'address': {
          'street': formData.get('address.street'),
          'city': formData.get('address.city')
        }
      };
    });

    final formData = dio_form_data.FormData.fromMap({
      'name': 'John Doe',
      'age': '30',
      'hobbies': ['reading', 'gaming', 'coding'],
      'address.street': '123 Main St',
      'address.city': 'New York'
    });

    final response = await dio.post('/formdata',
        data: formData,
        options: Options(
          headers: {'content-type': 'multipart/form-data'},
        ));

    var data = response.data;

    expect(data['name'], equals('John Doe'));
    expect(data['age'], equals('30'));
    expect(data['hobbies'], containsAll(['reading', 'gaming', 'coding']));
    expect(data['address']['street'], equals('123 Main St'));
    expect(data['address']['city'], equals('New York'));
  });

  test('FormData implementation follows spec', () {
    var formData = h4_formdata.FormData();

    // Test append and get
    formData.append('name', 'John Doe');
    expect(formData.get('name'), equals('John Doe'));
    expect(formData.has('name'), isTrue);

    // Test multiple values via append
    formData.append('hobbies', 'reading');
    formData.append('hobbies', 'gaming');
    formData.append('hobbies', 'coding');
    var hobbies = formData
        .entries()
        .firstWhere((e) => e.key == 'hobbies')
        .value
        .map((e) => e.value)
        .toList();
    expect(hobbies, containsAll(['reading', 'gaming', 'coding']));

    // Test set (should replace existing values)
    formData.set('hobbies', 'swimming');
    expect(formData.get('hobbies'), equals('swimming'));
    hobbies = formData
        .entries()
        .firstWhere((e) => e.key == 'hobbies')
        .value
        .map((e) => e.value)
        .toList();
    expect(hobbies.length, equals(1));

    // Test delete
    formData.delete('name');
    expect(formData.has('name'), isFalse);
    expect(formData.get('name'), isNull);

    // Test keys and values
    formData.set('age', '25');
    formData.set('city', 'New York');
    expect(formData.keys(), containsAll(['hobbies', 'age', 'city']));
    expect(formData.values().length, equals(3));

    // Test entries
    var entries = formData.entries();
    expect(entries.length, equals(3));
    var ageEntry = entries.firstWhere((e) => e.key == 'age');
    expect(ageEntry.value.first.value, equals('25'));

    // Test with file metadata
    formData.append('file', 'file-content',
        filename: 'test.txt', contentType: 'text/plain');
    var fileEntry =
        formData.entries().firstWhere((e) => e.key == 'file').value.first;
    expect(fileEntry.filename, equals('test.txt'));
    expect(fileEntry.contentType, equals('text/plain'));
  });
}
