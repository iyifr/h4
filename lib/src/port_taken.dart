import 'dart:io';

Future<bool> isPortAvailable({required int port}) async {
  try {
    ServerSocket socket = await ServerSocket.bind('localhost', port);
    await socket.close();
    return true;
  } on SocketException {
    return false;
  } catch (e) {
    return false;
  }
}
