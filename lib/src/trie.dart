import 'dart:core';
import 'package:h4/src/event.dart';
import 'package:h4/src/index.dart';
import 'package:h4/src/trie_traverse.dart';

class TrieNode {
  Map<String, TrieNode> children;
  bool isLeaf;
  Map<String, EventHandler?> handlers;

  TrieNode([EventHandler? handler, String method = "GET"])
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
    Map<String, EventHandler?>? laHandler;

    if (pathPieces.isEmpty) {
      return root.handlers;
    }

    TrieNode? currNode = root;

    for (String pathPiece in pathPieces) {
      int index = pathPieces.indexOf(pathPiece);

      if (currNode?.children[pathPiece] == null) {
        print(currNode);
        currNode?.children.forEach((key, value) {
          if ((key.startsWith(":") || key.startsWith("*")) && value.isLeaf) {
            if (index == pathPieces.length - 1) {
              laHandler = value.handlers;
            }
          }

          // Multiple Params
          if (key.startsWith(":") && !value.isLeaf) {
            var maps = deepTraverse(value.children);
            var result = maps["result"];
            var prev = maps["prev"];

            if (result?["leaf"] == pathPieces.lastOrNull) {
              laHandler = result?["handlers"];
            }

            if (result?["leaf"] != null) {
              if (result!["leaf"].startsWith(":")) {
                if (pathPieces[pathPieces.length - 2] == prev?["key"]) {
                  laHandler = result["handlers"];
                }
              }
            }
          }
        });
      }
      if (laHandler != null) {
        break;
      }
      currNode = currNode?.children[pathPiece];
    }
    return laHandler;
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

          if (key.startsWith("*")) {
            params[key.replaceAll("*", "_")] = pathPiece;
          }

          if (key.startsWith("**")) {
            params[key.replaceAll("**", "_")] = pathPiece;
          }
        });
      }
      currNode = currNode?.children[pathPiece];
    }
    return params;
  }

  matchWildCardRoute(List<String> pathPieces) {
    Map<String, EventHandler?>? laHandler;

    if (pathPieces.isEmpty) {
      return root.handlers;
    }

    TrieNode? currNode = root;

    for (String pathPiece in pathPieces) {
      if (currNode?.children[pathPiece] == null) {
        currNode?.children.forEach((key, value) {
          if (key.startsWith("**") && value.isLeaf) {
            laHandler = value.handlers;
          } else {
            var result = deepTraverse(value.children)["result"];
            if (result?["leaf"] == '**') {
              laHandler = result?["handlers"];
            }
          }
        });
      }
      currNode = currNode?.children[pathPiece];
    }
    return laHandler;
  }
}
