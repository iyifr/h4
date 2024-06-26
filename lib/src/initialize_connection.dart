import 'dart:async';
import 'dart:io';

Future<HttpServer>? initializeHttpConnection(
    {required int port,
    bool compress = false,
    // Default session timeout of 20 minutes expressed in seconds
    int sessionTimeout = 60 * 20}) async {
  final server = await HttpServer.bind('localhost', port, shared: true)
      .onError((e, stack) {
    print(e);
    throw 'Something went wrong';
  });
  server.autoCompress = compress;
  server.sessionTimeout = sessionTimeout;
  return server;
}
