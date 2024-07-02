List<String> extractPieces(String path) {
  List<String> result = path == '/' ? [] : path.split('/')
    ..removeWhere((piece) => piece.isEmpty);

  return result;
}
