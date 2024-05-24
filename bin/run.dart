// import 'package:console/console.dart' as console;

import 'package:h3/http-layer/H4.dart';
import 'package:h3/http-layer/index.dart';

void main(List<String> arguments) async {
  var router = H4Router((event) => "Hi");

  var app = createApp();
  app.use(router);

  router.post("/", (event) => "HIII");
}

class Person {
  String? name;
}

class Stack<E> {
  Stack() : _storage = <E>[];
  final List<E> _storage;
  var top = 0;

  @override
  String toString() {
    return '--- Top ---\n'
        '${_storage.reversed.join('\n')}'
        '\n-----------';
  }

  void printType() {
    print(_storage.runtimeType);
  }

  void push(E element) {
    _storage.add(element);
  }

  void pop() {
    _storage.removeLast();
  }
}

StringBuffer dartIsFun() {
  var message = StringBuffer('Dart is fun');
  for (var i = 0; i < 5; i++) {
    message.write('!');
  }
  return message;
}
