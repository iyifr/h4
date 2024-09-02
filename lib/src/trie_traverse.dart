import 'package:h4/src/trie.dart';

class TrieNodeStack<T> {
  final List<T> _items = [];

  void push(T item) {
    _items.add(item);
  }

  T pop() {
    return _items.removeLast();
  }

  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;
  String? get last => _items.toString();

  int get length => _items.length;

  T? val() {
    return _items.elementAtOrNull(length - 1);
  }

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

Map<String, Map<String, dynamic>> deepTraverse(Map<String, TrieNode> nodes) {
  TrieNodeStack<MapEntry<String, TrieNode>> stack =
      TrieNodeStack.from(nodes.entries);
  Map<String, dynamic> result = {'handlers': null, 'leaf': null};
  Map<String, dynamic> prev = {};

  while (stack.isNotEmpty) {
    MapEntry<String, TrieNode> entry = stack.pop();
    String key = entry.key;
    TrieNode value = entry.value;
    if (value.isLeaf) {
      result['handlers'] = value.handlers;
      result['leaf'] = key;
    } else if (value.children.isNotEmpty || !value.isLeaf) {
      prev['key'] = key;
      stack.addAll(value.children.entries);
    }
  }
  return {'result': result, 'prev': prev};
}

Map<String, dynamic> traverseTrieForSpecialChunks(Map<String, TrieNode> nodes) {
  TrieNodeStack<MapEntry<String, TrieNode>> stack =
      TrieNodeStack.from(nodes.entries);
  Map<String, dynamic> result = {};

  var prev = '';

  while (stack.isNotEmpty) {
    MapEntry<String, TrieNode> entry = stack.pop();
    String key = entry.key;
    TrieNode value = entry.value;

    if (key.startsWith(":")) {
      if (value.isLeaf) {
        key = key.replaceFirst(":", "");
        result[key] = {'leaf': true};
      } else {
        prev = '$prev/$key';
        key = key.replaceFirst(":", "");
        result[key] = {'leaf': false, 'prev': prev};
      }
    } else {
      prev = '$prev/$key';
    }

    // if (key.startsWith("*") || key.startsWith("**")) {
    //   key = key.replaceFirst("**", "_");
    //   result[key] = key;
    //   result[key] = key;
    // }

    if (value.children.isNotEmpty) {
      stack.addAll(value.children.entries);
    }
  }

  return result;
}
