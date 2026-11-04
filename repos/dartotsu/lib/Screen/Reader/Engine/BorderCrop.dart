import 'dart:typed_data';
import 'dart:ui' as ui;

import '../../../Logger.dart';

class BorderCropInfo {
  final ui.Rect? rect;
  final double width;
  final double height;

  const BorderCropInfo(this.rect, this.width, this.height);
}

class BorderCropCache {
  BorderCropCache._();

  static final _map = <String, BorderCropInfo>{};

  static BorderCropInfo? get(String key) => _map[key];

  static void put(String key, BorderCropInfo info) {
    _map.remove(key);
    _map[key] = info;
    if (_map.length > 400) _map.remove(_map.keys.first);
  }
}

bool _blank(int min, int max, int sum, int count) {
  if (max - min > 14) return false;
  final mean = sum / count;
  return mean >= 232 || mean <= 22;
}

ui.Rect? cropRectFromPixels(Uint8List rgba, int w, int h) {
  if (w < 8 || h < 8 || rgba.length < w * h * 4) return null;
  final lum = Uint8List(w * h);
  for (var i = 0; i < w * h; i++) {
    final o = i * 4;
    lum[i] = (rgba[o] * 77 + rgba[o + 1] * 150 + rgba[o + 2] * 29) >> 8;
  }

  bool rowBlank(int y) {
    var min = 255, max = 0, sum = 0;
    for (var x = 0; x < w; x++) {
      final v = lum[y * w + x];
      if (v < min) min = v;
      if (v > max) max = v;
      sum += v;
    }
    return _blank(min, max, sum, w);
  }

  var top = 0;
  while (top < h * 0.4 && rowBlank(top)) {
    top++;
  }
  var bottom = 0;
  while (bottom < h * 0.4 && rowBlank(h - 1 - bottom)) {
    bottom++;
  }
  if (top >= h * 0.4 || bottom >= h * 0.4) return null;

  bool colBlank(int x) {
    var min = 255, max = 0, sum = 0;
    for (var y = top; y < h - bottom; y++) {
      final v = lum[y * w + x];
      if (v < min) min = v;
      if (v > max) max = v;
      sum += v;
    }
    return _blank(min, max, sum, h - top - bottom);
  }

  var left = 0;
  while (left < w * 0.4 && colBlank(left)) {
    left++;
  }
  var right = 0;
  while (right < w * 0.4 && colBlank(w - 1 - right)) {
    right++;
  }
  if (left >= w * 0.4 || right >= w * 0.4) return null;

  top = top > 0 ? top - 1 : 0;
  bottom = bottom > 0 ? bottom - 1 : 0;
  left = left > 0 ? left - 1 : 0;
  right = right > 0 ? right - 1 : 0;
  final rect = ui.Rect.fromLTRB(
    left / w,
    top / h,
    1 - right / w,
    1 - bottom / h,
  );
  return rect.width * rect.height > 0.97 ? null : rect;
}

Future<ui.Rect?> detectBorders(ui.Image image) async {
  final iw = image.width;
  final ih = image.height;
  if (iw < 16 || ih < 16 || ih / iw > 2.4) return null;
  final tw = 96;
  final th = (ih * tw / iw).round().clamp(16, 400);
  try {
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawImageRect(
      image,
      ui.Rect.fromLTWH(0, 0, iw.toDouble(), ih.toDouble()),
      ui.Rect.fromLTWH(0, 0, tw.toDouble(), th.toDouble()),
      ui.Paint()..filterQuality = ui.FilterQuality.medium,
    );
    final small = await recorder.endRecording().toImage(tw, th);
    final data = await small.toByteData(format: ui.ImageByteFormat.rawRgba);
    small.dispose();
    if (data == null) return null;
    return cropRectFromPixels(data.buffer.asUint8List(), tw, th);
  } catch (e, st) {
    logError('BorderCrop', e, st, 'border detection failed');
    return null;
  }
}
