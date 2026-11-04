import 'package:flutter/material.dart';

class GlassTheme extends ThemeExtension<GlassTheme> {
  final BorderSide edge;

  const GlassTheme({required this.edge});

  static BorderSide? edgeOf(BuildContext context) =>
      Theme.of(context).extension<GlassTheme>()?.edge;

  @override
  GlassTheme copyWith({BorderSide? edge}) =>
      GlassTheme(edge: edge ?? this.edge);

  @override
  GlassTheme lerp(GlassTheme? other, double t) => other == null
      ? this
      : GlassTheme(edge: BorderSide.lerp(edge, other.edge, t));
}
