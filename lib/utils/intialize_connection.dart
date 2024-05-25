import 'dart:io';

Future<HttpServer> initializeHttpConnection() async {
  final server = await HttpServer.bind('localhost', 3000);
  print('Server listening on localhost:3000');
  return server;
}
