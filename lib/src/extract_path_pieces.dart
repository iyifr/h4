List<String> extractPieces(String path) {
  return path == '/' ? [] : path.split('/')
    ..removeWhere((piece) => piece.isEmpty);
}
