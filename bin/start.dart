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
  void cleanup({bool exitNow = true}) {
    // ignore: unnecessary_null_comparison
    if (serverProcess != null) {
      Console.resetAll();
      exitNow ? print('Terminating server process...') : null;
      serverProcess!.kill();
    }
    exitNow ? exit(0) : print('Restarting the server process...');
  }

  // Start the server as a child process
  if (results.flag('dev')) {
    watchDirectory('lib', handleFileChange: () async {
      cleanup(exitNow: false);
      serverProcess = await Process.start('dart', ['run', 'lib/index.dart']);
      // print('Server started with PID: ${serverProcess.pid}');
      Console.setBackgroundColor(7, bright: true);
      Console.setTextColor(3, bright: true);
      Console.write('\n ^-^ H4 CLI -- \n'.toUpperCase());
      Console.resetBackgroundColor();

      // Handle server process stdout
      serverProcess!.stdout.transform(utf8.decoder).listen((data) {
        Console.write(data);
      }).onDone(() {
        Console.resetTextColor();
        Console.setBold(false);
      });

      // Handle server process stderr
      serverProcess!.stderr.transform(utf8.decoder).listen((data) {
        print(data);
      });

      // Wait for the server process to exit
      final exitCode = await serverProcess!.exitCode;
      print('Server process exited with code: $exitCode');
    });
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

  try {
    var file = File("lib/index.dart");
    // await runH4App(serverProcess: serverProcess, file: file);
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
      serverProcess!.stdout.transform(utf8.decoder).listen((data) {
        Console.write('\n$data');
      }).onDone(() {
        Console.resetTextColor();
        Console.setBold(false);
      });

      // Handle server process stderr
      serverProcess!.stderr.transform(utf8.decoder).listen((data) {
        print(data);
      });

      // Wait for the server process to exit
      await serverProcess!.exitCode;
    }
  } catch (e) {
    print('Error starting server: $e');
    cleanup();
  }
}

void watchDirectory(String dirPath, {required handleFileChange}) {
  final watcher = DirectoryWatcher(dirPath);

  print('Watching directory: $dirPath');

  watcher.events.listen((event) async {
    // final relativePath = path.relative(event.path, from: dirPath);

    switch (event.type) {
      case ChangeType.MODIFY:
        await handleFileChange();
        break;
    }
  });
}
