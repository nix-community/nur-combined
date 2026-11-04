import 'dart:math' as math;

class ColorValues {
  final int brightness;
  final int contrast;
  final int saturation;
  final int gamma;
  final int hue;

  const ColorValues({
    this.brightness = 0,
    this.contrast = 0,
    this.saturation = 0,
    this.gamma = 0,
    this.hue = 0,
  });

  bool get isDefault =>
      brightness == 0 &&
      contrast == 0 &&
      saturation == 0 &&
      gamma == 0 &&
      hue == 0;

  ColorValues copyWith({
    int? brightness,
    int? contrast,
    int? saturation,
    int? gamma,
    int? hue,
  }) => ColorValues(
    brightness: brightness ?? this.brightness,
    contrast: contrast ?? this.contrast,
    saturation: saturation ?? this.saturation,
    gamma: gamma ?? this.gamma,
    hue: hue ?? this.hue,
  );

  @override
  bool operator ==(Object other) =>
      other is ColorValues &&
      other.brightness == brightness &&
      other.contrast == contrast &&
      other.saturation == saturation &&
      other.gamma == gamma &&
      other.hue == hue;

  @override
  int get hashCode => Object.hash(brightness, contrast, saturation, gamma, hue);
}

const colorPresets = <String, ColorValues>{
  'default': ColorValues(),
  'vivid': ColorValues(saturation: 25, contrast: 8),
  'pop': ColorValues(saturation: 35, contrast: 10, gamma: 5),
  'soft': ColorValues(contrast: -8, saturation: -5, brightness: 3),
  'cinematic': ColorValues(contrast: 15, saturation: -10, gamma: -5),
  'bright': ColorValues(brightness: 10, gamma: 8),
  'night': ColorValues(brightness: -8, contrast: 5, saturation: -5),
  'mono': ColorValues(saturation: -100),
};

String presetOf(ColorValues values) {
  for (final e in colorPresets.entries) {
    if (e.value == values) return e.key;
  }
  return 'custom';
}

List<double> colorMatrix(ColorValues v) {
  final contrast = 1 + v.contrast / 100;
  final sat = 1 + v.saturation / 100;
  final shift = (v.brightness / 100) * 0.5 * 255 + (v.gamma / 100) * 0.3 * 255;
  final angle = v.hue / 100 * math.pi;
  const lr = 0.2126, lg = 0.7152, lb = 0.0722;
  final s = [
    lr * (1 - sat) + sat,
    lg * (1 - sat),
    lb * (1 - sat),
    lr * (1 - sat),
    lg * (1 - sat) + sat,
    lb * (1 - sat),
    lr * (1 - sat),
    lg * (1 - sat),
    lb * (1 - sat) + sat,
  ];
  final c = math.cos(angle), n = math.sin(angle);
  final h = [
    lr + c * (1 - lr) - n * lr,
    lg - c * lg - n * lg,
    lb - c * lb + n * (1 - lb),
    lr - c * lr + n * 0.143,
    lg + c * (1 - lg) + n * 0.14,
    lb - c * lb - n * 0.283,
    lr - c * lr - n * (1 - lr),
    lg - c * lg + n * lg,
    lb + c * (1 - lb) + n * lb,
  ];
  final m = List<double>.filled(9, 0);
  for (var r = 0; r < 3; r++) {
    for (var col = 0; col < 3; col++) {
      for (var k = 0; k < 3; k++) {
        m[r * 3 + col] += h[r * 3 + k] * s[k * 3 + col];
      }
    }
  }
  final offset = 128 * (1 - contrast) + shift;
  return [
    m[0] * contrast,
    m[1] * contrast,
    m[2] * contrast,
    0,
    offset,
    m[3] * contrast,
    m[4] * contrast,
    m[5] * contrast,
    0,
    offset,
    m[6] * contrast,
    m[7] * contrast,
    m[8] * contrast,
    0,
    offset,
    0,
    0,
    0,
    1,
    0,
  ];
}
