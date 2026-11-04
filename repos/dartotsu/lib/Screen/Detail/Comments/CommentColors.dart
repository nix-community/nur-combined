import 'dart:math';

import 'package:flutter/material.dart';

const _palette = <int>[
  0xff9932cc,
  0xffa020f0,
  0xff8b008b,
  0xff7b68ee,
  0xffda70d6,
  0xffdda0dd,
  0xffffe4b5,
  0xfff0e68c,
  0xffffb6c1,
  0xfffa8072,
  0xffb03060,
  0xffff1493,
  0xffff00ff,
  0xffff69b4,
  0xffdc143c,
  0xff8b0000,
  0xffff0000,
  0xffa0522d,
  0xfff4a460,
  0xffb8860b,
  0xffffa500,
  0xffd2691e,
  0xffff6347,
  0xff808000,
  0xffffd700,
  0xffffff54,
  0xff8fbc8f,
  0xff3cb371,
  0xff008000,
  0xff00fa9a,
  0xff98fb98,
  0xff00ff00,
  0xffadff2f,
  0xff32cd32,
  0xff556b2f,
  0xff9acd32,
  0xff7fffd4,
  0xff2f4f4f,
  0xff5f9ea0,
  0xff87ceeb,
  0xff00bfff,
  0xff00ffff,
  0xff1e90ff,
  0xff4682b4,
  0xff0000ff,
  0xff0000cd,
  0xff00008b,
  0xff191970,
  0xffffffff,
];

int commentLevel(int votes) => votes < 0 ? 0 : sqrt(votes.abs() / 0.8).toInt();

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = max(la, lb);
  final lo = min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

Color commentLevelColor(int votes, Color background) {
  final level = min(commentLevel(votes), _palette.length - 1);
  var color = Color(_palette[level]);
  if (_contrast(color, background) >= 4.5) return color;
  final toward = background.computeLuminance() > 0.5
      ? Colors.black
      : Colors.white;
  for (var step = 1; step <= 20; step++) {
    final next = Color.lerp(color, toward, step * 0.05)!;
    if (_contrast(next, background) >= 4.5) return next;
  }
  return toward;
}

String commentAge(DateTime? time) {
  if (time == null) return 'just now';
  final diff = DateTime.now().difference(time);
  final days = diff.inDays;
  if (days >= 365) return '${days ~/ 365}y ago';
  if (days >= 30) return '${days ~/ 30}mo ago';
  if (days >= 7) return '${days ~/ 7}w ago';
  if (days > 0) return '${days}d ago';
  if (diff.inHours > 0) return '${diff.inHours}h ago';
  if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
  return 'just now';
}
