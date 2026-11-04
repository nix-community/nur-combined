import 'dart:ui';

import 'package:dartotsu_extension_bridge/Models/Page.dart';

class ReaderSegment {
  final int chapter;
  final List<PageUrl> pages;

  const ReaderSegment(this.chapter, this.pages);
}

sealed class ReaderItem {
  const ReaderItem();
}

class ReaderPage extends ReaderItem {
  final int segment;
  final int chapter;
  final int page;
  final int count;
  final PageUrl url;

  const ReaderPage({
    required this.segment,
    required this.chapter,
    required this.page,
    required this.count,
    required this.url,
  });
}

class ReaderSpread extends ReaderItem {
  final ReaderPage first;
  final ReaderPage second;

  const ReaderSpread(this.first, this.second);
}

class ReaderGap extends ReaderItem {
  final int chapter;
  final int? target;
  final bool atStart;

  const ReaderGap({
    required this.chapter,
    required this.target,
    required this.atStart,
  });
}

List<ReaderItem> buildReaderItems(
  List<ReaderSegment> segments, {
  required int chapterCount,
  bool spreads = false,
  bool startGap = true,
  int Function(int chapter)? nextOf,
}) {
  if (segments.isEmpty) return const [];
  final items = <ReaderItem>[];
  final first = segments.first.chapter;
  if (first > 0 && startGap) {
    items.add(ReaderGap(chapter: first, target: first - 1, atStart: true));
  }
  for (final (s, segment) in segments.indexed) {
    final pages = [
      for (final (i, url) in segment.pages.indexed)
        ReaderPage(
          segment: s,
          chapter: segment.chapter,
          page: i,
          count: segment.pages.length,
          url: url,
        ),
    ];
    if (spreads) {
      var i = 0;
      if (pages.isNotEmpty) items.add(pages[i++]);
      while (i < pages.length) {
        if (i + 1 < pages.length) {
          items.add(ReaderSpread(pages[i], pages[i + 1]));
          i += 2;
        } else {
          items.add(pages[i++]);
        }
      }
    } else {
      items.addAll(pages);
    }
    final next = nextOf?.call(segment.chapter) ?? segment.chapter + 1;
    items.add(
      ReaderGap(
        chapter: segment.chapter,
        target: next < chapterCount ? next : null,
        atStart: false,
      ),
    );
  }
  return items;
}

enum TapAction { previous, next, menu, none }

TapAction tapActionFor(
  String zones,
  Offset at, {
  required bool invert,
  bool reversed = false,
  bool topDown = false,
}) {
  final x = at.dx.clamp(0.0, 1.0);
  final y = at.dy.clamp(0.0, 1.0);
  if (zones == 'off') return TapAction.menu;
  if (topDown) {
    TapAction vertical;
    if (y < 0.2) {
      vertical = TapAction.previous;
    } else if (y > 0.8) {
      vertical = TapAction.next;
    } else {
      return TapAction.menu;
    }
    return invert ? _swap(vertical) : vertical;
  }
  TapAction result;
  switch (zones) {
    case 'off':
      return TapAction.menu;
    case 'lshaped':
      if (x < 0.33 || y < 0.33) {
        result = TapAction.previous;
      } else if (x > 0.66 || y > 0.66) {
        result = TapAction.next;
      } else {
        return TapAction.menu;
      }
    case 'kindle':
      if (y < 0.15) return TapAction.menu;
      result = x < 0.33 ? TapAction.previous : TapAction.next;
    case 'edge':
      if (x < 0.2) {
        result = TapAction.previous;
      } else if (x > 0.8) {
        result = TapAction.next;
      } else {
        return TapAction.menu;
      }
    default:
      if (x < 0.33) {
        result = TapAction.previous;
      } else if (x > 0.66) {
        result = TapAction.next;
      } else {
        return TapAction.menu;
      }
  }
  var flip = invert;
  if (reversed && zones != 'lshaped') flip = !flip;
  return flip ? _swap(result) : result;
}

TapAction _swap(TapAction a) => switch (a) {
  TapAction.previous => TapAction.next,
  TapAction.next => TapAction.previous,
  _ => a,
};
