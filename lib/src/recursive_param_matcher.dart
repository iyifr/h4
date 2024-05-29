import 'package:h4/src/trie.dart';

class Stack<T> {
  final List<T> _items = [];

  void push(T item) {
    _items.add(item);
  }

  T pop() {
    if (_items.isEmpty) {
      throw StateError('Stack is empty');
    }
    return _items.removeLast();
  }

  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  int get length => _items.length;

  void addAll(Iterable<T> items) {
    _items.addAll(items.toList().reversed);
  }

  static Stack<T> from<T>(Iterable<T> iterable) {
    final stack = Stack<T>();
    for (final item in iterable) {
      stack.push(item);
    }
    return stack;
  }
}

Map<String, dynamic> dynamicRecursive(Map<String, TrieNode> nodes) {
  Stack<MapEntry<String, TrieNode>> stack = Stack.from(nodes.entries);
  Map<String, dynamic> result = {'handlers': null, 'leaf': null};

  while (stack.isNotEmpty) {
    MapEntry<String, TrieNode> entry = stack.pop();
    String key = entry.key;
    TrieNode value = entry.value;

    if (value.isLeaf) {
      result['handlers'] = value.handlers;
      result['leaf'] = key;
      return result;
    } else if (value.children.isNotEmpty) {
      stack.addAll(value.children.entries);
    }
  }
  return result;
}
