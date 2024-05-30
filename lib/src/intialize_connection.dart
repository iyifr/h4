import 'dart:io';

Future<HttpServer> initializeHttpConnection({required int port}) async {
  final server = await HttpServer.bind('localhost', port, shared: true);
  print('Server listening on localhost:3000');
  return server;
}
