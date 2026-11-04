import 'package:flutter/material.dart';

import '../../Model/CardStyle.dart';
import 'Responsive.dart';

/// Layout maths for a [CardStyle], derived from the shared [Dimens.cardW] base
/// so every poster card scales together.
extension CardStyleMetrics on CardStyle {
  double get itemWidth => Dimens.cardW * scale;

  double get imageHeight => itemWidth * aspect;

  /// Height reserved below the poster for the caption — one info line for
  /// media, a two-line role/VA line for people (labelMedium, ~18px/line).
  double get _captionHeight => preset == 'people'
      ? 38
      : mayShowInfo
      ? 20
      : 0;

  /// bodyLarge reserves 24px per line, an upper bound for the font's own line
  /// height.
  double get _titleHeight => lines * 24;

  /// Height a horizontal shelf must reserve for one card in this style.
  double get itemHeight {
    switch (mode) {
      case CardMode.onCard:
        return imageHeight + 6;
      case CardMode.normal:
        return imageHeight + 7 + _titleHeight + _captionHeight + 6;
      case CardMode.inCard:
        // poster + progress bar + a padded text block on the same card surface
        // (top padding leaves room for the score badge straddling the seam)
        return imageHeight + 4 + 13 + _titleHeight + _captionHeight + 9 + 6;
    }
  }

  double itemHeightFor(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scaler = MediaQuery.textScalerOf(context);
    double line(TextStyle? style, int lines) {
      final painter = TextPainter(
        text: TextSpan(text: 'Ag', style: style),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
      )..layout();
      return painter.height * lines;
    }

    final title = line(text.bodyLarge, lines);
    final caption = preset == 'people'
        ? line(text.labelMedium, 2) + 2
        : mayShowInfo
        ? line(text.labelMedium, 1) + 2
        : 0.0;
    switch (mode) {
      case CardMode.onCard:
        return imageHeight + 6;
      case CardMode.normal:
        return imageHeight + 7 + title + caption + 6;
      case CardMode.inCard:
        return imageHeight + 4 + 13 + title + caption + 9 + 6;
    }
  }
}
