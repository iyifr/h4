import 'dart:async';
import 'dart:io';

Future<HttpServer>? initializeHttpConnection({
  required int port,
  bool compress = false,
}) async {
  final server = await HttpServer.bind('localhost', port, shared: true)
      .onError((e, stack) {
    print(e);
    throw 'Something went wrong';
  });
  server.autoCompress = compress;
  return server;
}
