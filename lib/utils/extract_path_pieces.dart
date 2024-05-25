extractPieces(String path) {
  final pathPieces = path == "/" ? [] : path.split("/");
  pathPieces.remove("");
  return pathPieces;
}