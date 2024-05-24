import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'dart:convert';

Future<HttpServer> initializeHttpConnection() async {
  final server = await HttpServer.bind('localhost', 3000);
  print('Server listening on localhost:3000');
  return server;
}

handleRequests(HttpServer server) async {
  server.listen((HttpRequest request) {
    switch (request.method) {
      case 'GET':
        {
          var action = defineEventHandler((event) => {
                "Hi": [1, 3, 5, 6, 10204, 3959]
              });
          action(request);
        }
      case 'POST':
        {
          var action = defineEventHandler((event) {
            event.statusCode = 404;
            print(event.path);
            return "Heello world";
          });
          action(request);
        }
      case 'PUT':
        {
          defineEventHandler((event) => [])(request);
        }
    }
  });
}

Future<dynamic> readBody(HttpRequest request) async {
  var rawBody = await request.toList();

  if (rawBody.isNotEmpty) {
    var string = '';

    for (int i = 0; i < rawBody.length; i++) {
      string += utf8.decode(rawBody[i]); // Outputs each character of the string
    }
    return string;
  }

  return null;
}

// Pass H4 Event instead of HTTPRequest
defineEventHandler(FutureOr<dynamic> Function(H4Event event) handler) {
  return (HttpRequest request) async {
    await readBody(request);

    final h4Event = H4Event(request);

    var handlerResult = handler(h4Event);

    if (handlerResult == null) {
      h4Event.setResponseFormatTo("null");
    }

    if (handlerResult.runtimeType == String) {
      h4Event.setResponseFormatTo("html");
    }

    if (handlerResult is Map<dynamic, dynamic> ||
        handlerResult is List<dynamic>) {
      h4Event.setResponseFormatTo("json");

      // Encode to jsonString
      handlerResult = jsonEncode(handlerResult);
    }

    h4Event._respond(handlerResult);
  };
}

class H4Event {
  H4Event(this._request);

  final HttpRequest _request;
  bool handled = false;

// Methods, getters and setters
  String get path => _request.uri.path;

  String get method => _request.method.toUpperCase();

  set statusCode(int code) {
    _request.response.statusCode = code;
  }

  Map<String, HttpRequest> get node => {'value': _request};

  HttpHeaders get headers => _request.headers;

  setResponseFormatTo(String type) {
    switch (type) {
      case 'html':
        _request.response.headers
            .add(HttpHeaders.contentTypeHeader, "text/html");

      case 'json':
        _request.response.headers
            .add(HttpHeaders.contentTypeHeader, "application/json");

      case 'null':
        _request.response.statusCode = 204;
    }
  }

  _respond(dynamic handlerResult) {
    if (!handled) {
      _request.response.write(handlerResult);
      _request.response.close();
      handled = true;
    }
  }
}

typedef HandlerFunc = FutureOr<dynamic> Function(H4Event event);

class H4Router {
  Trie routes;

  H4Router(HandlerFunc handler) : routes = Trie(handler);

  get(String path, HandlerFunc handler) {
    // Deconstruct route
    final pathPieces = path == "/" ? [] : path.split("/");
    pathPieces.remove("");
    routes.insert(pathPieces, handler, "GET");
  }

  post(String path, HandlerFunc handler) {
    // Deconstruct route
    final pathPieces = path.split("/");
    routes.insert(pathPieces, handler, "POST");
  }

  lookup(path) {
    final pathPieces = path == "/" ? [] : path.split("/");
    pathPieces.remove("");
    return routes.search(pathPieces);
  }
}

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
}
