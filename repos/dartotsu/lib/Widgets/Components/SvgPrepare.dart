import 'dart:convert';
import 'dart:typed_data';

import '../../Utils/Font/WebFont.dart';

class PreparedSvg {
  final String svg;
  final Map<String, Uint8List> fonts;

  const PreparedSvg(this.svg, this.fonts);
}

final _nestedImage = RegExp(
  r'''<image\b[^>]*?\b(?:xlink:)?href\s*=\s*["']data:image/svg\+xml;base64,([A-Za-z0-9+/=\s]+)["'][^>]*?/?>''',
  caseSensitive: false,
  dotAll: true,
);
final _styleBlock = RegExp(
  r'<style\b[^>]*>([\s\S]*?)</style>',
  caseSensitive: false,
);
final _fontFace = RegExp(
  r'''@font-face\s*\{([^}]*)\}''',
  caseSensitive: false,
);
final _fontFamily = RegExp(
  r'''font-family\s*:\s*["']?([^"';}]+?)["']?\s*(?:;|$)''',
  caseSensitive: false,
);
final _fontData = RegExp(
  r'''url\(\s*["']?data:[^;,]*;base64,([A-Za-z0-9+/=\s]+)["']?\s*\)''',
  caseSensitive: false,
);
final _shadowRect = RegExp(
  r'''<rect\b[^>]*\bfill\s*=\s*["']#0{3,6}["'][^>]*\bfilter\s*=\s*["'][^"']*["'][^>]*/>''',
  caseSensitive: false,
);
final _filterAttr = RegExp(
  r'''\sfilter\s*=\s*["'][^"']*["']''',
  caseSensitive: false,
);
final _fontAttr = RegExp(r'''font-family\s*=\s*"([^"]+)"''');
final _rootTag = RegExp(r'<svg\b[^>]*>', caseSensitive: false);

String? _attr(String tag, String name) => RegExp(
  '(?:^|\\s)$name\\s*=\\s*["\']([^"\']*)["\']',
  caseSensitive: false,
).firstMatch(tag)?.group(1);

double? _number(String? value) =>
    value == null ? null : double.tryParse(value.replaceAll(RegExp('[a-z%]'), ''));

bool needsPreparing(String svg) =>
    svg.contains('data:image/svg+xml') ||
    svg.contains('@font-face') ||
    svg.contains(' filter=');

PreparedSvg prepareSvg(String source, {int depth = 0}) {
  final fonts = <String, Uint8List>{};
  var svg = source.replaceFirst(RegExp('^\uFEFF'), '');

  if (depth < 3) {
    svg = svg.replaceAllMapped(_nestedImage, (m) {
      try {
        final inner = prepareSvg(
          utf8.decode(base64.decode(m.group(1)!.replaceAll(RegExp(r'\s'), ''))),
          depth: depth + 1,
        );
        fonts.addAll(inner.fonts);
        return _inline(m.group(0)!, inner.svg);
      } catch (_) {
        return '';
      }
    });
  }

  svg = svg.replaceAllMapped(_styleBlock, (m) {
    for (final face in _fontFace.allMatches(m.group(1)!)) {
      final rule = face.group(1)!;
      final family = _fontFamily.firstMatch(rule)?.group(1);
      final data = _fontData.firstMatch(rule)?.group(1);
      if (family == null || data == null) continue;
      try {
        final sfnt = webFontToSfnt(
          base64.decode(data.replaceAll(RegExp(r'\s'), '')),
        );
        if (sfnt != null) fonts[family.trim()] = sfnt;
      } catch (_) {}
    }
    return '';
  });

  svg = svg.replaceAll(_shadowRect, '').replaceAll(_filterAttr, '');

  if (fonts.isNotEmpty) {
    svg = svg.replaceAllMapped(_fontAttr, (m) {
      final names = m.group(1)!;
      final first = names.split(',').first.trim().replaceAll(RegExp('["\']'), '');
      final bytes = fonts[first];
      return bytes == null
          ? m.group(0)!
          : 'font-family="${fontFamilyFor(first, bytes)}"';
    });
  }
  return PreparedSvg(svg, fonts);
}

String fontFamilyFor(String family, Uint8List bytes) =>
    'svg_${family.replaceAll(RegExp(r'[^A-Za-z0-9]'), '_')}_${bytes.length}';

String _inline(String imageTag, String innerSvg) {
  final root = _rootTag.firstMatch(innerSvg);
  final close = innerSvg.toLowerCase().lastIndexOf('</svg>');
  if (root == null || close < root.end) return '';
  final body = innerSvg.substring(root.end, close);
  final rootTag = root.group(0)!;
  final viewBox = (_attr(rootTag, 'viewBox') ?? '')
      .split(RegExp(r'[\s,]+'))
      .map(double.tryParse)
      .toList();
  final innerW =
      viewBox.length == 4 && viewBox[2] != null
          ? viewBox[2]!
          : _number(_attr(rootTag, 'width')) ?? 0;
  final innerH =
      viewBox.length == 4 && viewBox[3] != null
          ? viewBox[3]!
          : _number(_attr(rootTag, 'height')) ?? 0;
  final minX = viewBox.length == 4 ? viewBox[0] ?? 0 : 0.0;
  final minY = viewBox.length == 4 ? viewBox[1] ?? 0 : 0.0;
  final x = _number(_attr(imageTag, 'x')) ?? 0;
  final y = _number(_attr(imageTag, 'y')) ?? 0;
  final w = _number(_attr(imageTag, 'width')) ?? innerW;
  final h = _number(_attr(imageTag, 'height')) ?? innerH;
  if (innerW <= 0 || innerH <= 0 || w <= 0 || h <= 0) return body;
  final scale = [w / innerW, h / innerH].reduce((a, b) => a < b ? a : b);
  final dx = x + (w - innerW * scale) / 2 - minX * scale;
  final dy = y + (h - innerH * scale) / 2 - minY * scale;
  return '<g transform="translate($dx $dy) scale($scale)">$body</g>';
}
