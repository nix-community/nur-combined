import 'dart:io';

import 'package:path/path.dart' as p;

import '../../../Core/Preferences/StorageManager.dart';
import 'ColorPresets.dart';

String colorShaderSource(ColorValues v) {
  final m = colorMatrix(v);
  String f(double x) => x.toStringAsFixed(6);
  final off = m[4] / 255;
  return '''//!HOOK OUTPUT
//!BIND HOOKED
//!DESC dartotsu color

vec4 hook() {
    vec4 c = HOOKED_texOff(0);
    vec3 rgb = c.rgb;
    vec3 o;
    o.r = dot(rgb, vec3(${f(m[0])}, ${f(m[1])}, ${f(m[2])})) + ${f(off)};
    o.g = dot(rgb, vec3(${f(m[5])}, ${f(m[6])}, ${f(m[7])})) + ${f(off)};
    o.b = dot(rgb, vec3(${f(m[10])}, ${f(m[11])}, ${f(m[12])})) + ${f(off)};
    return vec4(clamp(o, 0.0, 1.0), c.a);
}
''';
}

Future<String?> colorShaderPath(ColorValues v) async {
  if (v.isDefault) return null;
  final dir = await StorageManager.getDirectory(subPath: 'cache/mpv/color');
  if (dir == null) return null;
  final name =
      'color_${v.brightness}_${v.contrast}_${v.saturation}_${v.gamma}_${v.hue}.glsl'
          .replaceAll('-', 'm');
  final file = File(p.join(dir.path, name));
  if (!await file.exists()) {
    await for (final old in dir.list()) {
      if (old is File) await old.delete();
    }
    await file.writeAsString(colorShaderSource(v), flush: true);
  }
  return file.path;
}
