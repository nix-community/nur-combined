import 'Media.dart';

class CalendarEntry {
  final Media media;
  final int? episode;
  final DateTime airingAt;
  final bool expected;
  final bool chapter;
  final String? source;
  final void Function()? open;

  const CalendarEntry({
    required this.media,
    this.episode,
    required this.airingAt,
    this.expected = false,
    this.chapter = false,
    this.source,
    this.open,
  });
}
