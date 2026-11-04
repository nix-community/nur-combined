import '../../Detail/Watch/Data/Providers/MetaHttp.dart';
import 'AniSkip.dart';

List<SkipStamp> parseTheIntroDb(Object? body) {
  if (body is! Map) return const [];
  final stamps = <SkipStamp>[];

  void add(String key, SkipKind kind, String name) {
    final list = body[key];
    if (list is! List) return;
    for (final item in list) {
      if (item is! Map) continue;
      final start = (item['start_ms'] as num?)?.toDouble() ?? 0;
      final end = (item['end_ms'] as num?)?.toDouble();
      if (end == null || end <= start) continue;
      stamps.add(SkipStamp(name, kind, start / 1000, end / 1000));
    }
  }

  add('intro', SkipKind.opening, 'Opening');
  add('credits', SkipKind.ending, 'Ending');
  add('recap', SkipKind.recap, 'Recap');
  add('preview', SkipKind.other, 'Preview');
  stamps.sort((a, b) => a.start.compareTo(b.start));
  return stamps;
}

List<SkipStamp> parseIntroDbApp(Object? body) {
  if (body is! Map) return const [];
  final stamps = <SkipStamp>[];

  void add(String key, SkipKind kind, String name) {
    final item = body[key];
    if (item is! Map) return;
    final start = (item['start_sec'] as num?)?.toDouble() ?? 0;
    final end = (item['end_sec'] as num?)?.toDouble();
    if (end == null || end <= start) return;
    stamps.add(SkipStamp(name, kind, start, end));
  }

  add('intro', SkipKind.opening, 'Opening');
  add('outro', SkipKind.ending, 'Ending');
  add('recap', SkipKind.recap, 'Recap');
  stamps.sort((a, b) => a.start.compareTo(b.start));
  return stamps;
}

class IntroDb {
  IntroDb._();

  static const theIntroDbUrl = 'https://api.theintrodb.org/v4/media';
  static const introDbAppUrl = 'https://api.introdb.app/segments';

  static Future<List<SkipStamp>> fetch({
    String? imdbId,
    int? tvdbId,
    int? tmdbId,
    int season = 1,
    required int episode,
    int? durationMs,
    bool isMovie = false,
  }) async {
    if (imdbId != null) {
      final stamps = parseIntroDbApp(
        await metaGet(
          introDbAppUrl,
          query: {
            'imdb_id': imdbId,
            'season': '$season',
            'episode': '$episode',
          },
          tag: 'INTRODB',
        ),
      );
      if (stamps.isNotEmpty) return stamps;
    }
    final keys = <Map<String, String>>[
      if (tvdbId != null) {'tvdb_id': '$tvdbId'},
      if (tmdbId != null) {'tmdb_id': '$tmdbId'},
      if (imdbId != null) {'imdb_id': imdbId},
    ];
    for (final key in keys) {
      final stamps = parseTheIntroDb(
        await metaGet(
          theIntroDbUrl,
          query: {
            ...key,
            if (!isMovie) 'season': '$season',
            if (!isMovie) 'episode': '$episode',
            if (durationMs != null && durationMs > 0)
              'duration_ms': '$durationMs',
          },
          tag: 'THEINTRODB',
        ),
      );
      if (stamps.isNotEmpty) return stamps;
    }
    return const [];
  }
}
