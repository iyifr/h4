import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:console/console.dart';
import 'package:path/path.dart' as path;
import 'package:watcher/watcher.dart';

void main(List<String> args) async {
  var parser = ArgParser();

  parser.addFlag('dev', abbr: 'd');

  var results = parser.parse(args);

  Process? serverProcess;

  // Function to handle cleanup and exit
  void cleanup() {
    // ignore: unnecessary_null_comparison
    if (serverProcess != null) {
      Console.resetAll();
      print('Terminating server process...');
      serverProcess.kill();
    }
    exit(0);
  }

  // Set up signal handling for graceful shutdown
  if (Platform.isWindows) {
    // Windows only supports sigint
    ProcessSignal.sigint.watch().listen((_) => cleanup());
  } else {
    // Unix-like systems support both sigint and sigterm
    ProcessSignal.sigint.watch().listen((_) => cleanup());
    ProcessSignal.sigterm.watch().listen((_) => cleanup());
  }

  runH4App({required Process? serverProcess, required File file}) async {
    if (!file.existsSync()) {
      print('ERROR: Could not find your server at lib/index.dart');
      print(
          'ERROR:Create lib/index.dart with your h4 server and re-run the command');
      exit(0);
    } else {
      serverProcess = await Process.start('dart', ['run', 'lib/index.dart']);
      // print('Server started with PID: ${serverProcess.pid}');
      Console.setBackgroundColor(7, bright: true);
      Console.setTextColor(3, bright: true);
      Console.write('\n ^-^ H4 CLI -- \n'.toUpperCase());
      Console.resetBackgroundColor();

      // Handle server process stdout
      serverProcess.stdout.transform(utf8.decoder).listen((data) {
        Console.write('\n$data');
      }).onDone(() {
        Console.resetTextColor();
        Console.setBold(false);
      });

      // Handle server process stderr
      serverProcess.stderr.transform(utf8.decoder).listen((data) {
        print(data);
      });

      // Wait for the server process to exit
      final exitCode = await serverProcess.exitCode;
      print('Server process exited with code: $exitCode');
    }
  }

  try {
    var file = File("lib/index.dart");
    await runH4App(serverProcess: serverProcess, file: file);

    // Start the server as a child process
    if (results.flag('dev')) {
      watchDirectory('lib', handleFileChange: () async {
        if (serverProcess is Process) {
          serverProcess.kill();
        }
        Console.write('\nChange detected - restarting server \n');
        await runH4App(serverProcess: serverProcess, file: file);
      });
    }
  } catch (e) {
    print('Error starting server: $e');
    cleanup();
  }
}

void watchDirectory(String dirPath, {required handleFileChange}) {
  final watcher = DirectoryWatcher(dirPath);

  print('Watching directory: $dirPath');

  watcher.events.listen((event) {
    final relativePath = path.relative(event.path, from: dirPath);

    switch (event.type) {
      case ChangeType.ADD:
        print('File added: $relativePath');
        break;
      case ChangeType.MODIFY:
        handleFileChange();
        print('File modified: $relativePath');
        break;
      case ChangeType.REMOVE:
        print('File removed: $relativePath');
        break;
    }
  });
}
