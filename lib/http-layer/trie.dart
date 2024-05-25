import 'dart:async';
import 'dart:core';
import 'package:h3/http-layer/event.dart';

typedef HandlerFunc = FutureOr<dynamic> Function(H4Event event);

class TrieNode {
  Map<String, TrieNode> children;
  bool? isLeaf;
  Map<String, HandlerFunc?> handlers;

  TrieNode([HandlerFunc? handler, String method = "GET"])
      : children = {},
        isLeaf = false,
        handlers = {method: handler};

  addChild(String character) {
    if (children[character] == null) {
      children[character] = TrieNode();
    }
    return children[character];
  }

  TrieNode? getChild(String character) {
    return children[character];
  }

  setLeaf(Function(H4Event event) handler, [String method = "GET"]) {
    isLeaf = true;
    handlers[method] = handler;
  }
}

class Trie {
  TrieNode root;

  Trie([dynamic Function(H4Event event)? rootHandler])
      : root = TrieNode(rootHandler);

  insert(List<dynamic> pathPieces, dynamic Function(H4Event event) handler,
      [String method = "GET"]) {
    TrieNode currentNode = root;

    for (String pathPiece in pathPieces) {
      currentNode = currentNode.addChild(pathPiece);
    }
    currentNode.setLeaf(handler, method);
  }

  search(List<dynamic> pathPieces) {
    if (pathPieces.isEmpty) {
      return root.handlers;
    }

    TrieNode? currNode = root;
    for (String pathPiece in pathPieces) {
      if (currNode?.children[pathPiece] == null) {
        return null;
      }
      currNode = currNode?.children[pathPiece];
    }
    return currNode?.handlers;
  }

  matchParamRoute(List<String> pathPieces) {
    Map<String, HandlerFunc?>? laHandler;

    if (pathPieces.isEmpty) {
      return root.handlers;
    }

    TrieNode? currNode = root;
    for (String pathPiece in pathPieces) {
      if (currNode?.children[pathPiece] == null) {
        currNode?.children.forEach((key, value) {
          if (key.startsWith(":") && value.isLeaf!) {
            laHandler = value.handlers;
          }
        });
        return laHandler;
      }
      currNode = currNode?.children[pathPiece];
    }
  }

  Map<String, String> getParams(pathPieces) {
    Map<String, String> params = {};
    TrieNode? currNode = root;
    for (String pathPiece in pathPieces) {
      if (currNode?.children[pathPiece] == null) {
        currNode?.children.forEach((key, value) {
          if (key.startsWith(":")) {
            params[key.replaceAll(":", "")] = pathPiece;
          }
        });
      }
      currNode = currNode?.children[pathPiece];
    }
    print(params);
    return params;
  }
}
