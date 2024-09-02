import 'package:h4/src/logger.dart';

List<String> extractPieces(String path) {
  if (!isValidHttpPathPattern(path)) {
    logger.severe('Invalid http path, Got - $path');
  }
  List<String> result = path == '/' ? [] : path.split('/')
    ..removeWhere((piece) => piece.isEmpty);

  return result;
}

bool isValidHttpPathPattern(String pattern) {
  final regex = RegExp(
    r'^(?:'
    r'/'
    r'|/(?:[\p{L}\p{N}_-]+(?:/[\p{L}\p{N}_-]+)*/?)'
    r'|/(?:[\p{L}\p{N}_-]+/)*(?::[\p{L}\p{N}_]+)(?:/[\p{L}\p{N}_-]+)*(?:/(?:[\p{L}\p{N}_-]+/)*(?::[\p{L}\p{N}_]+)(?:/[\p{L}\p{N}_-]+)*)*/?'
    r'|/[\p{L}\p{N}_-]+/:[^/]+/\*\*'
    r'|/[\p{L}\p{N}_-]+/\*\*'
    r'|/[\p{L}\p{N}_-]+/\*'
    r'| '
    r'|\*'
    r')$',
    unicode: true,
  );
  return regex.hasMatch(pattern);
}
