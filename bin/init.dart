// ignore_for_file: unnecessary_string_escapes

import 'dart:async';
import 'dart:io';
import 'package:console/console.dart';
import 'dart:convert';

void main(List<String> arguments) async {
  if (!await _isH4Installed()) {
    _printH4AsciiArt();
    final choice = await _promptUserChoice();
    if (choice == 'create_in_current') {
      await _initH4InCurrentDirectory();
      printArt();
    } else {
      final appName = await _promptAppName();
      await _createAppFiles(appName);
      printArt();
    }
  } else {
    printArt();
    await _writeMainFile(File('bin/main.dart'));
  }
  Console.resetAll();
}

Future<void> _initH4InCurrentDirectory() async {
  Console.setUnderline(true);
  Console.setTextColor(4, bright: true);
  Console.write('\n\nCreating a new H4 app... \n'.toUpperCase());
  Console.setUnderline(false);

  try {
    await _createAppFiles('', inCurrentDir: true);
  } catch (e) {
    Console.write('\nFailed to create app files');
  }

  try {
    await Process.run('dart', ['pub', 'add', 'h4']);
    Console.setBackgroundColor(0);
    Console.setTextColor(6);
    Console.write('\nH4 installed successfully'.toUpperCase());
    await _writeMainFile(File('bin/main.dart'));
  } catch (e) {
    Console.write('\nFailed to install the \'h4\' package. Error: $e');
    return;
  } finally {
    Console.resetAll();
  }
}

Future<void> _createAppFiles(String appName,
    {bool inCurrentDir = false}) async {
  Console.setBackgroundColor(7, bright: true);
  Console.setTextColor(0);
  Console.write('\nCreating a new H4 app in - /$appName');
  Console.resetBackgroundColor();

  try {
    Process.runSync('dart', [
      'create',
      '--template=console',
      '--force',
      inCurrentDir ? '.' : appName
    ]);

    Console.setBlink(true);
    Console.setBold(true);
    Console.write('\n\nInstalling necessary dependencies...\n'.toUpperCase());
    dynamic mainFile;

    if (inCurrentDir) {
      Process.runSync('dart', ['pub', 'add', 'h4'],
          workingDirectory: Directory.current.path);
      mainFile = File('bin/main.dart');
    } else {
      mainFile = File('$appName/bin/main.dart');
      await runProcessInDirectory(appName, ['dart', 'pub', 'add', 'h4']);
    }

    Console.setBlink(false);
    Console.setBold(false);
    await _writeMainFile(mainFile);
    Console.setBold(true);
    Console.write('\nH4 initialized successfully'.toUpperCase());
  } catch (e) {
    Console.write('\nFailed to create H4 app. Error: $e');
    return;
  }
}

Future<bool> _isH4Installed() async {
  try {
    final pubspecFile = File('pubspec.yaml');
    if (!await pubspecFile.exists()) {
      return false;
    }

    final pubspecContents = await pubspecFile.readAsString();
    return pubspecContents.contains('dependencies:\n  h4:');
  } catch (e) {
    return false;
  }
}

Future<String?> _promptUserChoice() async {
  Console.setTextColor(3, bright: true);
  Console.write('Select an option:');
  Console.write('\n1. Create app in current directory \n');
  Console.write('\n2. Create app in new directory \n');
  Console.setTextColor(2, bright: true);
  Console.write('\nEnter your choice (1 or 2): ');
  var choice = stdin.readLineSync(encoding: utf8) ?? '';
  var invalid = false;

  if (choice == '1' || choice == '2') {
    Console.resetTextColor();
    return choice == '1' ? 'create_in_current' : 'create_in_new';
  } else {
    invalid = true;
    while (invalid) {
      Console.write('\nInvalid choice Enter your choice (1 or 2): ');
      choice = stdin.readLineSync(encoding: utf8) ?? '';
      if (choice == '1' || choice == '2') {
        invalid = false;
        Console.resetTextColor();
        return choice == '1' ? 'create_in_current' : 'create_in_new';
      }
    }
  }
  return null;
}

Future<String> _promptAppName() async {
  Console.setTextColor(6, bright: true);
  Console.setBold(true);
  Console.write(
      '\nEnter a name for your app (or press Enter to skip and set default): ');
  final name = stdin.readLineSync(encoding: utf8) ?? '';
  Console.resetAll();
  return name.isNotEmpty ? name : 'my-app';
}

Future<void> _writeMainFile(File mainFile) async {
  await mainFile.writeAsString('''
import 'package:h4/create.dart';

void main() async {
  var app = createApp(
    port: 5173,
    onRequest: (event) => {},
    onError: (error, stacktrace, event) => {},
    afterResponse: (event) => {},
  );

  var router = createRouter();
  app.use(router);

  router.get("/", (event) {
    return 'Hello world';
  });
}
''');
}

void _printH4AsciiArt() {
  Console.setTextColor(6, bright: true);
  Console.write('''

    _-_         ___^        
    | |__      // ||
    | '_ \    //  ||
    | | | |   \___-|
    |_| |_|       ||

''');
}

void printArt() {
  Console.setTextColor(4, bright: true);
  Console.write('''

╭━━━━━━━━━━━━━━━━━━━━━━━━╮
    ┃    ╭─────╮  ╭─────╮    ┃
    ┃ ╭──┤ h-4  ├───┤REIGNS├──╮ ┃
    ┃ │  ╰─────╯   ╰─────╯  │ ┃
    ┃ │    ╭───────────╮    │ ┃
    ┃ │ in │ ╭─────╮   │ the│ ┃
    ┃ ╰────┤ │TIME│ ├────╯ ┃
    ┃      │ ╰─────╯   │      ┃
    ┃      ╰───────────╯      ┃
    ╰━━━━━━━━━━━━━━━━━━━━━━━━╯
       ╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱
      ╱   F U T U R E   ╱
     ╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱

''');
}

Future<ProcessResult> runProcessInDirectory(
    String directory, List<String> arguments) async {
  try {
    final result = await Process.run(arguments.first, arguments.sublist(1),
        workingDirectory: './$directory');
    return result;
  } catch (e) {
    throw Exception('Error running process in directory: $e');
  }
}
