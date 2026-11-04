import '../../../../Core/Services/Model/Media.dart';
import '../../../../Core/Services/Model/News.dart';
import 'Mapper.dart';

class StackOwner {
  final String username;
  final String name;

  const StackOwner(this.username, this.name);

  String get label => name.isEmpty ? username : name;
}

class StackEntry {
  final int rank;
  final String? note;
  final Media media;

  const StackEntry(this.rank, this.note, this.media);
}

class MangaBakaStack {
  final int id;
  final String title;
  final String url;
  final String kind;
  final String visibility;
  final String contentRating;
  final bool spoiler;
  final bool featured;
  final StackOwner owner;
  final int entryCount;
  final int voteCount;
  final int saveCount;
  final List<String> covers;
  final String? description;
  final List<StackEntry> entries;

  const MangaBakaStack({
    required this.id,
    required this.title,
    required this.url,
    required this.kind,
    required this.visibility,
    required this.contentRating,
    required this.spoiler,
    required this.featured,
    required this.owner,
    required this.entryCount,
    required this.voteCount,
    required this.saveCount,
    required this.covers,
    this.description,
    this.entries = const [],
  });

  bool get adult =>
      contentRating == 'erotica' || contentRating == 'pornographic';

  static MangaBakaStack placeholder = const MangaBakaStack(
    id: 0,
    title: 'Loading stack title',
    url: '',
    kind: 'personal',
    visibility: 'public',
    contentRating: 'safe',
    spoiler: false,
    featured: false,
    owner: StackOwner('user', 'Loading'),
    entryCount: 12,
    voteCount: 3,
    saveCount: 4,
    covers: [],
  );
}

class StackPage {
  final List<MangaBakaStack> items;
  final bool hasNext;

  const StackPage(this.items, this.hasNext);
}

String? _cover(Object? raw) {
  if (raw is! Map) return null;
  for (final key in ['x350', 'x250', 'raw', 'x150']) {
    final value = raw[key];
    if (value is String && value.isNotEmpty) return value;
  }
  return null;
}

int _int(Object? v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;

MangaBakaStack parseStack(Map<String, dynamic> j) {
  final owner = j['owner'];
  final entries = <StackEntry>[];
  for (final e in (j['entries'] as List?) ?? const []) {
    if (e is! Map || e['series'] is! Map) continue;
    final series = (e['series'] as Map).cast<String, dynamic>();
    if (series['id'] == null) continue;
    entries.add(
      StackEntry(
        _int(e['rank']),
        e['note'] as String?,
        mapMangaBakaSeries(series),
      ),
    );
  }
  return MangaBakaStack(
    id: _int(j['id']),
    title: '${j['title'] ?? ''}',
    url: '${j['canonical_url'] ?? ''}',
    kind: '${j['kind'] ?? 'personal'}',
    visibility: '${j['visibility'] ?? 'public'}',
    contentRating: '${j['content_rating'] ?? 'safe'}',
    spoiler: j['is_spoiler'] == true,
    featured: j['is_featured'] == true,
    owner: owner is Map
        ? StackOwner('${owner['username'] ?? ''}', '${owner['name'] ?? ''}')
        : const StackOwner('', ''),
    entryCount: _int(j['entry_count']),
    voteCount: _int(j['vote_count']),
    saveCount: _int(j['save_count']),
    covers: [
      for (final c in (j['covers'] as List?) ?? const [])
        if (c is Map) ?_cover(c['cover']),
    ],
    description: j['description'] as String?,
    entries: entries,
  );
}

StackPage parseStackPage(Map<String, dynamic> body) {
  final pagination = body['pagination'];
  return StackPage([
    for (final s in (body['data'] as List?) ?? const [])
      if (s is Map) parseStack(s.cast<String, dynamic>()),
  ], pagination is Map && pagination['next'] != null);
}

const _sources = {
  'ann': 'Anime News Network',
  'anilist': 'AniList',
  'mangaupdates': 'MangaUpdates',
};

NewsItem parseNews(Map<String, dynamic> j) {
  final source = '${j['source_name'] ?? ''}';
  return NewsItem(
    id: _int(j['id']),
    title: '${j['title'] ?? ''}',
    url: '${j['url'] ?? ''}',
    source: _sources[source.toLowerCase()] ?? source,
    author: j['author'] as String?,
    published: DateTime.tryParse('${j['published_at'] ?? ''}'),
    series: [
      for (final s in (j['series'] as List?) ?? const [])
        if (s is Map && s['id'] != null)
          mapMangaBakaSeries(s.cast<String, dynamic>()),
    ],
  );
}

NewsPage parseNewsPage(Map<String, dynamic> body) {
  final pagination = body['pagination'];
  return NewsPage([
    for (final n in (body['data'] as List?) ?? const [])
      if (n is Map) parseNews(n.cast<String, dynamic>()),
  ], pagination is Map && pagination['next'] != null);
}
