import 'package:h4/src/extract_path_pieces.dart';
import 'package:h4/src/index.dart';
import 'package:h4/src/trie.dart';

class H4Router {
  Trie routes;

  H4Router([EventHandler? handler]) : routes = Trie(handler);

  /// Handles **GET** requests.
  ///
  /// The event handler will only run if a **GET** request is made to the specified `path`.
  ///
  /// This function is generic, you can specify the return type of your handler by passing a serializable type.
  get<T>(String path, EventHandler<T> handler) {
    routes.insert(extractPieces(path), handler, "GET");
  }

  /// Handles **POST** requests.
  ///
  /// The event handler will only run if a POST request is made to the specified `path`.
  post<T>(String path, EventHandler<T> handler) {
    routes.insert(extractPieces(path), handler, "POST");
  }

  /// Handles `PUT` requests.
  ///
  /// The event handler will only run if a PUT request is made to the specified `path`.
  put<T>(String path, EventHandler<T> handler) {
    routes.insert(extractPieces(path), handler, "PUT");
  }

  /// Handles `PATCH` requests.
  ///
  /// The handler will only run if a **PATCH** request is made to the specified `path`.
  patch<T>(String path, EventHandler<T> handler) {
    routes.insert(extractPieces(path), handler, "PATCH");
  }

  /// Handles `DELETE` request.
  ///
  /// The event handler will only run if a **DELETE** request is made to the specified `path`.
  delete<T>(String path, EventHandler<T> handler) {
    routes.insert(extractPieces(path), handler, "DELETE");
  }

  /// Search through the route prefix tree to find the node holding the handler to our request.
  ///
  /// This returns an object that contains the following:
  /// - A normalized request method string [GET, POST, PUT, DELETE, PATCH]
  Map<String, EventHandler?>? lookup(path) {
    var pathChunks = extractPieces(path);

    var result = routes.search(pathChunks);

    result ??= routes.matchParamRoute(pathChunks);
    result ??= routes.matchWildCardRoute(pathChunks);

    return result;
  }

  Map<String, String> getParams(String path) {
    return routes.getParams(extractPieces(path));
  }
}
