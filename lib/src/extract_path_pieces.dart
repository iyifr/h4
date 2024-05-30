extractPieces(String path) {
  final pathPieces = path == "/" ? [] : path.split("/");
  pathPieces.remove("");

  if (pathPieces.lastOrNull == "") {
    pathPieces.removeLast();
  }
  return pathPieces;
}
