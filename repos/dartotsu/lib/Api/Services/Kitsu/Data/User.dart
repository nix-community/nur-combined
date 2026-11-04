import '../../../../Core/Services/ScoreFormat.dart';
import '../../../../Core/Services/ServiceAuth.dart';

class KitsuUser implements ServiceUser {
  @override
  final int id;
  @override
  final String name;
  final String slug;
  @override
  final String? avatar;
  @override
  final String? banner;
  @override
  final int episodesWatched;
  @override
  final int chaptersRead;
  final String titleLanguage;
  final String ratingSystem;
  final String contentFilter;
  final bool shareToGlobal;
  final String? timeZone;
  final String? country;
  final String? language;

  const KitsuUser({
    required this.id,
    required this.name,
    this.slug = '',
    this.avatar,
    this.banner,
    this.episodesWatched = 0,
    this.chaptersRead = 0,
    this.titleLanguage = 'canonical',
    this.ratingSystem = 'regular',
    this.contentFilter = 'sfw',
    this.shareToGlobal = true,
    this.timeZone,
    this.country,
    this.language,
  });

  @override
  int get unreadNotifications => 0;

  @override
  ScoreFormat get scoreFormat => switch (ratingSystem) {
    'simple' => ScoreFormat.point3,
    'advanced' => ScoreFormat.point10Decimal,
    _ => ScoreFormat.point5,
  };

  String get profileUrl => 'https://kitsu.io/users/${slug.isEmpty ? id : slug}';

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'avatar': avatar,
    'banner': banner,
    'episodes': episodesWatched,
    'chapters': chaptersRead,
    'titleLanguage': titleLanguage,
    'ratingSystem': ratingSystem,
    'contentFilter': contentFilter,
    'shareToGlobal': shareToGlobal,
    'timeZone': timeZone,
    'country': country,
    'language': language,
  };

  factory KitsuUser.fromJson(Map<String, dynamic> j) => KitsuUser(
    id: (j['id'] as num).toInt(),
    name: j['name'] as String,
    slug: j['slug'] as String? ?? '',
    avatar: j['avatar'] as String?,
    banner: j['banner'] as String?,
    episodesWatched: (j['episodes'] as num?)?.toInt() ?? 0,
    chaptersRead: (j['chapters'] as num?)?.toInt() ?? 0,
    titleLanguage: j['titleLanguage'] as String? ?? 'canonical',
    ratingSystem: j['ratingSystem'] as String? ?? 'regular',
    contentFilter: j['contentFilter'] as String? ?? 'sfw',
    shareToGlobal: j['shareToGlobal'] as bool? ?? true,
    timeZone: j['timeZone'] as String?,
    country: j['country'] as String?,
    language: j['language'] as String?,
  );

  KitsuUser withCounts({int? episodes, int? chapters}) => KitsuUser(
    id: id,
    name: name,
    slug: slug,
    avatar: avatar,
    banner: banner,
    episodesWatched: episodes ?? episodesWatched,
    chaptersRead: chapters ?? chaptersRead,
    titleLanguage: titleLanguage,
    ratingSystem: ratingSystem,
    contentFilter: contentFilter,
    shareToGlobal: shareToGlobal,
    timeZone: timeZone,
    country: country,
    language: language,
  );
}
