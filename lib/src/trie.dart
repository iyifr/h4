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

  // Search route trie for parameterized routes.
  matchParamRoute(List<String> pathPieces) {
    Map<String, EventHandler?>? eventHandler;

    if (pathPieces.isEmpty) {
      return root.handlers;
    }

    TrieNode? currNode = root;

    for (String pathPiece in pathPieces) {
      int index = pathPieces.indexOf(pathPiece);

      if (currNode?.children[pathPiece] == null) {
        currNode?.children.forEach((key, value) {
          if ((RegExp(r'^[:*]').hasMatch(key)) && value.isLeaf) {
            if (index == pathPieces.length - 1) {
              eventHandler = value.handlers;
            }
          }

          // Multiple Params
          if ((RegExp(r'^[:*]').hasMatch(key)) && !value.isLeaf) {
            var maps = deepTraverse(value.children);
            var result = maps["result"];
            var prev = maps["prev"];

            if (result?["leaf"] == pathPieces.lastOrNull) {
              eventHandler = result?["handlers"];
            }

            if (result?["leaf"] != null) {
              if (result!["leaf"].startsWith(":")) {
                if (pathPieces[pathPieces.length - 2] == prev?["key"]) {
                  eventHandler = result["handlers"];
                }
              }
            }
          }
        });
      }
      if (eventHandler != null) break;
      currNode = currNode?.children[pathPiece];
    }
    return eventHandler;
  }

  Map<String, String> getParams(List<String> pathPieces) {
    Map<String, dynamic> params = {};
    TrieNode? currNode = root;
    params = traverseTrieForSpecialChunks(currNode.children);
    Map<String, String> theprms = {};

    params.forEach((key, value) {
      if (value["leaf"] == true) {
        theprms[key] = pathPieces.lastOrNull ?? "";
      } else {
        List<String> nw = value["prev"].split("/");
        var placeholderChunks = nw..removeWhere((item) => item.isEmpty);
        theprms.addEntries(
            matchPlaceholders(placeholderChunks, pathPieces).entries);
      }
    });
    return theprms;
  }

  matchWildCardRoute(List<String> pathPieces) {
    Map<String, EventHandler?>? eventHandler;

    if (pathPieces.isEmpty) {
      return root.handlers;
    }

    TrieNode? currNode = root;

    for (String pathPiece in pathPieces) {
      if (currNode?.children[pathPiece] == null) {
        currNode?.children.forEach((key, value) {
          if (key.startsWith("**") && value.isLeaf) {
            eventHandler = value.handlers;
          } else {
            var result = deepTraverse(value.children)["result"];
            if (result?["leaf"] == '**') {
              eventHandler = result?["handlers"];
            }
          }
        });
      }
      currNode = currNode?.children[pathPiece];
    }
    return eventHandler;
  }
}

Map<String, String> matchPlaceholders(
    List<String> placeholder, List<String> realString) {
  Map<String, String> replacements = {};

  // Iterate only up to the length of the placeholder list
  for (int i = 0; i < placeholder.length; i++) {
    // Check if we're still within the bounds of the realString
    if (i < realString.length) {
      if (placeholder[i].startsWith(':')) {
        replacements[placeholder[i].replaceFirst(':', '')] = realString[i];
      } else if (placeholder[i] != realString[i]) {
        // Non-placeholder elements must match exactly
        return {};
      }
    } else {
      // realString is shorter than placeholder
      return {};
    }
  }

  return replacements;
}
