import 'package:logging/logging.dart';

var logger = Logger('H4');

initLogger() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.message}');
  });
}
