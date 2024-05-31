import 'package:h4/src/trie.dart';

class TrieNodeStack<T> {
  final List<T> _items = [];

  void push(T item) {
    _items.add(item);
  }

  T pop() {
    if (_items.isEmpty) {
      // throw StateError('Stack is empty');
    }
    return _items.removeLast();
  }

  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  int get length => _items.length;

  void addAll(Iterable<T> items) {
    _items.addAll(items.toList().reversed);
  }

  static TrieNodeStack<T> from<T>(Iterable<T> iterable) {
    final stack = TrieNodeStack<T>();
    for (final item in iterable) {
      stack.push(item);
    }
    return stack;
  }
}

Map<String, dynamic> deepTraverse(Map<String, TrieNode> nodes) {
  TrieNodeStack<MapEntry<String, TrieNode>> stack =
      TrieNodeStack.from(nodes.entries);
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
