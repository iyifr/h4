import 'package:logging/logging.dart';
import 'package:console/console.dart';

var logger = Logger('H4');

initLogger() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    switch (record.level.name) {
      case 'INFO':
        {
          Console.setBackgroundColor(6, bright: true);
          Console.setTextColor(2, bright: true);
          // ignore: unnecessary_string_escapes
          Console.write('\n ${record.level.name} ');
          Console.resetBackgroundColor();
          Console.resetTextColor();
          Console.setBold(false);
          Console.write(' ▲▼▲▼▲▼ ${record.message}\n');
          Console.resetAll();
        }

      case 'SEVERE':
        {
          Console.setFramed(true);
          Console.write(record.level.name);
          Console.write(record.message);
        }
    }
  });
}
