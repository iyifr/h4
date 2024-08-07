import 'dart:io';

import 'package:h4/src/logger.dart';

Future<bool> isPortAvailable({required int port}) async {
  try {
    ServerSocket socket = await ServerSocket.bind('localhost', port);
    await socket.close();
    return true;
  } on SocketException {
    logger.info('Port $port is in use, trying port ${port + 1}');
    return false;
  } catch (e) {
    logger.info('Port $port is in use, trying port ${port + 1}');
    return false;
  }
}
