import '../../Logger.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import '../State/State.dart';
import '../ThemeManager/CustomFontLoader.dart';

const bundledFont = 'Manrope';

String migrateFont(String value) => value == 'Poppins' ? bundledFont : value;

final fontsTick = 0.live;

final _families = <String, String>{};
final _loading = <String>{};

bool isFontFile(String value) => value.contains('/') || value.contains('\\');

String fontLabel(String value, String appFont) {
  if (value.isEmpty) return appFont;
  if (isFontFile(value)) return p.basenameWithoutExtension(value);
  return value;
}

String? fontFamilyOf(String value) {
  if (value.isEmpty) return null;
  if (!isFontFile(value)) return value;
  final family = _families[value];
  if (family == null && _loading.add(value)) unawaited(_load(value));
  return family;
}

Future<void> _load(String path) async {
  try {
    final family = await CustomFontLoader.load(path);
    if (family != null) {
      _families[path] = family;
      fontsTick.value++;
    }
  } finally {
    _loading.remove(path);
  }
}

Future<List<String>> savedFontFiles() => CustomFontLoader.listSavedFonts();

Future<String> importFontFile(String path) => CustomFontLoader.importFont(path);

String? fontInternalName(String path) {
  try {
    final data = File(path).readAsBytesSync();
    final view = ByteData.sublistView(data);
    var base = 0;
    if (view.getUint32(0) == 0x74746366) base = view.getUint32(12);
    final tables = view.getUint16(base + 4);
    for (var i = 0; i < tables; i++) {
      final at = base + 12 + i * 16;
      if (String.fromCharCodes(data.sublist(at, at + 4)) != 'name') continue;
      final table = view.getUint32(at + 8);
      final count = view.getUint16(table + 2);
      final strings = table + view.getUint16(table + 4);
      String? family;
      for (var r = 0; r < count; r++) {
        final rec = table + 6 + r * 12;
        final id = view.getUint16(rec + 6);
        if (id != 1 && id != 16) continue;
        final platform = view.getUint16(rec);
        final length = view.getUint16(rec + 8);
        final offset = strings + view.getUint16(rec + 10);
        final bytes = data.sublist(offset, offset + length);
        final name = platform == 3 || platform == 0
            ? String.fromCharCodes([
                for (var k = 0; k + 1 < bytes.length; k += 2)
                  (bytes[k] << 8) | bytes[k + 1],
              ])
            : String.fromCharCodes(bytes);
        if (id == 16) return name;
        family ??= name;
      }
      return family;
    }
  } catch (e, st) {
    logError('AppFonts', e, st);
  }
  return null;
}
