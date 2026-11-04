import 'dart:typed_data';

import 'Woff.dart';

Uint8List? webFontToSfnt(Uint8List bytes) {
  final (result, sfnt) = decodeFontIfWoff(bytes);
  return result == WoffDecodeResult.ok || result == WoffDecodeResult.notWoff
      ? sfnt
      : null;
}
