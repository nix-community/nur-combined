import 'dart:async';

import 'package:flutter/painting.dart';

import 'NovelText.dart';

const novelIndent = '  ';

double headingScale(int heading) => switch (heading) {
  1 => 1.5,
  2 => 1.35,
  3 => 1.2,
  0 => 1.0,
  _ => 1.1,
};

TextStyle paragraphStyle(TextStyle base, int heading) => heading > 0
    ? base.copyWith(
        fontSize: base.fontSize! * headingScale(heading),
        fontWeight: FontWeight.w700,
      )
    : base;

class PageSlice {
  final int block;
  final int start;
  final int end;

  const PageSlice(this.block, this.start, this.end);
}

class NovelPage {
  final List<PageSlice> slices;

  const NovelPage(this.slices);

  int get firstBlock => slices.isEmpty ? 0 : slices.first.block;
}

class PageLayout {
  final TextStyle base;
  final TextScaler scaler;
  final double width;
  final double height;
  final double gap;
  final bool indent;

  const PageLayout({
    required this.base,
    required this.scaler,
    required this.width,
    required this.height,
    required this.gap,
    required this.indent,
  });

  double get pictureHeight => (height * 0.72).clamp(120.0, width * 1.4);

  double get ruleHeight => gap * 2 + 16;

  @override
  bool operator ==(Object other) =>
      other is PageLayout &&
      other.base == base &&
      other.scaler == scaler &&
      other.width == width &&
      other.height == height &&
      other.gap == gap &&
      other.indent == indent;

  @override
  int get hashCode => Object.hash(base, scaler, width, height, gap, indent);
}

int pageOfBlock(
  List<NovelPage> pages,
  List<NovelBlock> blocks,
  int block,
  double within,
) {
  if (pages.isEmpty) return 0;
  var hit = -1;
  for (var i = 0; i < pages.length; i++) {
    for (final s in pages[i].slices) {
      if (s.block != block) continue;
      if (hit < 0) hit = i;
      final b = blocks[block];
      final length = b is NovelParagraph ? b.text.length : 0;
      final at = (within * length).floor();
      if (at >= s.start && (at < s.end || s.end >= length)) return i;
    }
    if (hit >= 0 && pages[i].slices.every((s) => s.block > block)) break;
  }
  if (hit >= 0) return hit;
  for (var i = 0; i < pages.length; i++) {
    if (pages[i].slices.any((s) => s.block >= block)) return i;
  }
  return pages.length - 1;
}

Future<List<NovelPage>> paginate(
  List<NovelBlock> blocks,
  PageLayout layout, {
  required bool Function() cancelled,
  void Function(List<NovelPage> pages)? onPartial,
}) async {
  final pages = <NovelPage>[];
  var slices = <PageSlice>[];
  var used = 0.0;
  final clock = Stopwatch()..start();
  var lastPublish = 0;

  void flush() {
    if (slices.isEmpty) return;
    pages.add(NovelPage(slices));
    slices = [];
    used = 0;
  }

  final painter = TextPainter(textDirection: TextDirection.ltr);
  for (var i = 0; i < blocks.length; i++) {
    if (cancelled()) return pages;
    if (clock.elapsedMilliseconds > 12) {
      clock.reset();
      if (onPartial != null && pages.length - lastPublish >= 8) {
        lastPublish = pages.length;
        onPartial(List.of(pages));
      }
      await Future<void>.delayed(Duration.zero);
      if (cancelled()) return pages;
    }
    final b = blocks[i];
    switch (b) {
      case NovelMark():
        slices.add(PageSlice(i, 0, 0));
      case NovelRule():
        final h = layout.ruleHeight;
        if (used + h > layout.height && slices.isNotEmpty) flush();
        slices.add(PageSlice(i, 0, 0));
        used += h;
      case NovelPicture():
        final h = layout.pictureHeight + layout.gap;
        if (used + h > layout.height && slices.isNotEmpty) flush();
        slices.add(PageSlice(i, 0, 0));
        used += h;
      case NovelParagraph p:
        final style = paragraphStyle(layout.base, p.heading);
        final text = p.text;
        var start = 0;
        while (start < text.length) {
          final top = start == 0 && p.heading > 0 ? layout.gap : 0.0;
          final prefix = start == 0 && layout.indent && p.heading == 0
              ? novelIndent
              : '';
          painter
            ..text = TextSpan(
              text: prefix + text.substring(start),
              style: style,
            )
            ..textScaler = layout.scaler
            ..layout(maxWidth: layout.width);
          final remaining = layout.height - used - top;
          final whole = painter.height;
          if (whole + layout.gap <= remaining + 0.5 ||
              (whole <= remaining + 0.5 && slices.isEmpty)) {
            slices.add(PageSlice(i, start, text.length));
            used += top + whole + layout.gap;
            start = text.length;
            break;
          }
          final lines = painter.computeLineMetrics();
          var fit = 0;
          var height = 0.0;
          for (final line in lines) {
            if (height + line.height > remaining + 0.5) break;
            height += line.height;
            fit++;
          }
          if (fit == lines.length) {
            slices.add(PageSlice(i, start, text.length));
            used += top + whole + layout.gap;
            start = text.length;
            break;
          }
          if ((fit == 0 || (fit == 1 && lines.length > 2)) &&
              slices.isNotEmpty) {
            flush();
            continue;
          }
          if (fit == 0) {
            fit = 1;
            height = lines.first.height;
          }
          var cut =
              painter.getPositionForOffset(Offset(0, height + 1)).offset -
              prefix.length;
          if (cut <= 0 || cut >= text.length - start) {
            cut = (text.length - start) ~/ 2;
            if (cut <= 0) cut = text.length - start;
          }
          slices.add(PageSlice(i, start, start + cut));
          start += cut;
          flush();
        }
    }
  }
  flush();
  return pages;
}
