import 'MangaUpdates.dart';

class MuForecast {
  final int nextChapter;
  final int lastChapter;
  final DateTime lastRelease;
  final DateTime expected;
  final Duration interval;

  const MuForecast({
    required this.nextChapter,
    required this.lastChapter,
    required this.lastRelease,
    required this.expected,
    required this.interval,
  });
}

final _chapterNumber = RegExp(r'\d+(?:\.\d+)?');

double? muChapterNumber(String? raw) {
  if (raw == null) return null;
  double? best;
  for (final match in _chapterNumber.allMatches(raw)) {
    final value = double.tryParse(match.group(0)!);
    if (value != null && (best == null || value > best)) best = value;
  }
  return best;
}

MuForecast? predictNextChapter(
  List<MuRelease> releases, {
  bool completed = false,
  DateTime? now,
}) {
  if (completed) return null;
  final at = now ?? DateTime.now();
  final first = <int, DateTime>{};
  for (final release in releases) {
    final number = muChapterNumber(release.chapter);
    final date = release.date;
    if (number == null || date == null) continue;
    final key = number.floor();
    final seen = first[key];
    if (seen == null || date.isBefore(seen)) first[key] = date;
  }
  if (first.length < 3) return null;

  final chapters = first.keys.toList()..sort();
  final recent = chapters.length > 9
      ? chapters.sublist(chapters.length - 9)
      : chapters;
  final gaps = <double>[];
  for (var i = 1; i < recent.length; i++) {
    final days =
        first[recent[i]]!.difference(first[recent[i - 1]]!).inMinutes / 1440;
    if (days >= 0.25) gaps.add(days);
  }
  if (gaps.isEmpty) return null;
  gaps.sort();
  final middle = gaps.length ~/ 2;
  final median = gaps.length.isOdd
      ? gaps[middle]
      : (gaps[middle - 1] + gaps[middle]) / 2;
  final interval = Duration(minutes: (median.clamp(1.0, 90.0) * 1440).round());

  final lastChapter = chapters.last;
  final lastRelease = first[lastChapter]!;
  final elapsed = at.difference(lastRelease);
  if (elapsed > interval * 3 || elapsed > const Duration(days: 120)) {
    return null;
  }

  var expected = lastRelease.add(interval);
  if (expected.isBefore(at)) {
    final steps = (elapsed.inMinutes / interval.inMinutes).ceil();
    expected = lastRelease.add(interval * steps);
  }
  return MuForecast(
    nextChapter: lastChapter + 1,
    lastChapter: lastChapter,
    lastRelease: lastRelease,
    expected: expected,
    interval: interval,
  );
}
