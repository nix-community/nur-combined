import '../../../../Core/Services/Model/MediaReaction.dart';
import '../../../../Core/Services/Model/Anime.dart';
import '../../../../Core/Services/Model/Author.dart';
import '../../../../Core/Services/Model/Character.dart';
import '../../../../Core/Services/Model/Date.dart';
import '../../../../Core/Services/Model/Manga.dart';
import '../../../../Core/Services/Model/Media.dart';
import '../../../../Core/Services/Model/Review.dart';
import '../../../../Core/Services/Model/Studio.dart';
import '../../../../Core/Services/Model/User.dart';

String kitsuMediaId(bool anime, Object id) =>
    '${anime ? 'anime' : 'manga'}/$id';

(bool, int)? parseKitsuMediaId(String id) {
  final parts = id.split('/');
  if (parts.length == 1) {
    final n = int.tryParse(parts[0]);
    return n == null ? null : (true, n);
  }
  final n = int.tryParse(parts[1]);
  return n == null ? null : (parts[0] != 'manga', n);
}

String kitsuShareLink(bool anime, Object slug) =>
    'https://kitsu.io/${anime ? 'anime' : 'manga'}/$slug';

class JsonApi {
  final Map<String, dynamic> body;
  final Map<String, Map<String, dynamic>> _index;

  JsonApi(this.body)
    : _index = {
        for (final i in (body['included'] as List?) ?? const [])
          '${(i as Map)['type']}:${i['id']}': i.cast<String, dynamic>(),
      };

  List<Map<String, dynamic>> get data {
    final raw = body['data'];
    if (raw is List) return [for (final e in raw) (e as Map).cast()];
    if (raw is Map) return [raw.cast()];
    return const [];
  }

  String? get next => (body['links'] as Map?)?['next'] as String?;

  int? get count => ((body['meta'] as Map?)?['count'] as num?)?.toInt();

  Map<String, dynamic>? resolve(Object? ref) {
    if (ref is! Map) return null;
    return _index['${ref['type']}:${ref['id']}'];
  }

  Map<String, dynamic>? one(Map<String, dynamic> node, String rel) {
    final data = ((node['relationships'] as Map?)?[rel] as Map?)?['data'];
    return data is Map ? resolve(data) : null;
  }

  List<Map<String, dynamic>> many(Map<String, dynamic> node, String rel) {
    final data = ((node['relationships'] as Map?)?[rel] as Map?)?['data'];
    if (data is! List) return const [];
    return [for (final ref in data) ?resolve(ref)];
  }
}

Map<String, dynamic> attrs(Map<String, dynamic> node) =>
    (node['attributes'] as Map?)?.cast<String, dynamic>() ?? const {};

String? kitsuImage(
  Object? image, [
  List<String> order = const ['large', 'original', 'medium', 'small'],
]) {
  if (image is! Map) return null;
  for (final key in order) {
    final url = image[key];
    if (url is String && url.isNotEmpty) return url;
  }
  return null;
}

const _statusIn = {
  'current': 'CURRENT',
  'planned': 'PLANNING',
  'completed': 'COMPLETED',
  'on_hold': 'PAUSED',
  'dropped': 'DROPPED',
};

const _statusOut = {
  'CURRENT': 'current',
  'PLANNING': 'planned',
  'COMPLETED': 'completed',
  'PAUSED': 'on_hold',
  'DROPPED': 'dropped',
  'REPEATING': 'current',
};

String? kitsuStatusOut(String? status) => _statusOut[status];

String? kitsuStatusIn(String? status, {bool repeating = false}) =>
    repeating ? 'REPEATING' : _statusIn[status];

String? _airStatus(String? s) => switch (s) {
  'current' => 'RELEASING',
  'finished' => 'FINISHED',
  'upcoming' || 'unreleased' || 'tba' => 'NOT_YET_RELEASED',
  _ => null,
};

String? _format(String? subtype) {
  if (subtype == null || subtype.isEmpty) return null;
  return switch (subtype.toLowerCase()) {
    'oneshot' => 'ONE_SHOT',
    _ => subtype.toUpperCase(),
  };
}

Date? parseKitsuDate(Object? raw) {
  if (raw is! String || raw.length < 4) return null;
  final day = raw.split('T').first.split('-').map(int.tryParse).toList();
  return Date(
    year: day.isNotEmpty ? day[0] : null,
    month: day.length > 1 ? day[1] : null,
    day: day.length > 2 ? day[2] : null,
  );
}

String? kitsuDateOut(Date? d) {
  if (d?.year == null) return null;
  final m = (d!.month ?? 1).toString().padLeft(2, '0');
  final day = (d.day ?? 1).toString().padLeft(2, '0');
  return '${d.year}-$m-${day}T00:00:00.000Z';
}

int? kitsuEpoch(Object? iso) {
  final t = iso is String ? DateTime.tryParse(iso) : null;
  return t == null ? null : t.millisecondsSinceEpoch ~/ 1000;
}

int? _positive(Object? v) {
  final n = (v as num?)?.toInt();
  return n == null || n <= 0 ? null : n;
}

String? _season(Date? start) {
  final m = start?.month;
  if (m == null) return null;
  if (m == 12 || m <= 2) return 'WINTER';
  if (m <= 5) return 'SPRING';
  if (m <= 8) return 'SUMMER';
  return 'FALL';
}

String _titleCase(String s) => s
    .replaceAll('_', ' ')
    .split(' ')
    .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
    .join(' ');

class KitsuExtras {
  int? ratingRank;
  int? popularityRank;
  int? scoredBy;
  int? volumes;
  String? ageRating;
  String? ageGuide;
  List<(String, String)> links = const [];
}

final kitsuExtras = Expando<KitsuExtras>('kitsuExtras');

Media mapKitsuMedia(Map<String, dynamic> node, {JsonApi? doc}) {
  final a = attrs(node);
  final anime = node['type'] != 'manga';
  final titles = (a['titles'] as Map?)?.cast<String, dynamic>() ?? const {};
  final canonical = a['canonicalTitle'] as String?;
  String? title(String key) {
    final v = (titles[key] as String?)?.trim();
    return v == null || v.isEmpty ? null : v;
  }

  final english = title('en') ?? title('en_us') ?? canonical;
  final romaji = title('en_jp') ?? canonical;
  final rating = double.tryParse('${a['averageRating']}');
  final start = parseKitsuDate(a['startDate']);
  final trailerId = a['youtubeVideoId'] as String?;
  final slug = (a['slug'] as String?) ?? '${node['id']}';
  final categories = doc == null
      ? const <Map<String, dynamic>>[]
      : doc.many(node, 'categories');
  Studio? studio;
  if (doc != null && anime) {
    for (final p in doc.many(node, 'animeProductions')) {
      if (attrs(p)['role'] != 'studio') continue;
      final producer = doc.one(p, 'producer');
      if (producer == null) continue;
      studio = Studio(
        id: '${producer['id']}',
        name: attrs(producer)['name'] as String? ?? '',
      );
      break;
    }
  }
  final media = Media(
    id: kitsuMediaId(anime, node['id']),
    name: english,
    nameRomaji: romaji,
    cover: kitsuImage(a['posterImage']),
    banner: kitsuImage(a['coverImage'], const ['large', 'original', 'small']),
    isAdult: a['nsfw'] == true || a['ageRating'] == 'R18',
    meanScore: rating?.round(),
    genres: [
      for (final c in categories)
        if (attrs(c)['nsfw'] != true && attrs(c)['title'] is String)
          attrs(c)['title'] as String,
    ],
    status: _airStatus(a['status'] as String?),
    format: _format(a['subtype'] as String?),
    description: (a['synopsis'] as String?)?.trim(),
    synonyms: [
      for (final s in (a['abbreviatedTitles'] as List?) ?? const [])
        if (s is String && s.isNotEmpty) s,
      if (title('ja_jp') != null) title('ja_jp')!,
    ],
    trailer: trailerId == null || trailerId.isEmpty
        ? null
        : 'https://www.youtube.com/watch?v=$trailerId',
    startDate: start,
    endDate: parseKitsuDate(a['endDate']),
    popularity: (a['userCount'] as num?)?.toInt(),
    favourites: (a['favoritesCount'] as num?)?.toInt(),
    shareLink: kitsuShareLink(anime, slug),
    anime: anime
        ? Anime(
            totalEpisodes: _positive(a['episodeCount']),
            episodeDuration: _positive(a['episodeLength']),
            season: _season(start),
            seasonYear: start?.year,
            studio: studio,
          )
        : null,
    manga: anime ? null : Manga(totalChapters: _positive(a['chapterCount'])),
  );
  final frequencies = a['ratingFrequencies'] as Map?;
  kitsuExtras[media] = KitsuExtras()
    ..ratingRank = (a['ratingRank'] as num?)?.toInt()
    ..popularityRank = (a['popularityRank'] as num?)?.toInt()
    ..volumes = _positive(a['volumeCount'])
    ..ageRating = a['ageRating'] as String?
    ..ageGuide = a['ageRatingGuide'] as String?
    ..scoredBy = frequencies?.values.fold<int>(
      0,
      (sum, v) => sum + (int.tryParse('$v') ?? 0),
    );
  if (doc != null) {
    _relations(media, node, doc);
    _links(media, node, doc);
  }
  return media;
}

void _relations(Media media, Map<String, dynamic> node, JsonApi doc) {
  final related = <Media>[];
  for (final rel in doc.many(node, 'mediaRelationships')) {
    final dest = doc.one(rel, 'destination');
    if (dest == null) continue;
    final role = attrs(rel)['role'] as String?;
    final m = mapKitsuMedia(dest)
      ..relation = role == null ? null : _titleCase(role);
    related.add(m);
    if (role == 'prequel') media.prequel ??= m;
    if (role == 'sequel') media.sequel ??= m;
  }
  if (related.isNotEmpty) media.relations = related;
}

void _links(Media media, Map<String, dynamic> node, JsonApi doc) {
  final out = <(String, String)>[];
  for (final link in doc.many(node, 'streamingLinks')) {
    final url = attrs(link)['url'] as String?;
    if (url == null || url.isEmpty) continue;
    final streamer = doc.one(link, 'streamer');
    final name = attrs(streamer ?? const {})['siteName'] as String?;
    out.add((name ?? Uri.tryParse(url)?.host ?? url, url));
  }
  if (out.isNotEmpty) (kitsuExtras[media] ??= KitsuExtras()).links = out;
}

void applyKitsuEntry(Media media, Map<String, dynamic> entry) {
  final a = attrs(entry);
  final rating = (a['ratingTwenty'] as num?)?.toInt() ?? 0;
  media
    ..userStatus = kitsuStatusIn(
      a['status'] as String?,
      repeating: a['reconsuming'] == true,
    )
    ..userScore = rating * 5
    ..userProgress = (a['progress'] as num?)?.toInt() ?? 0
    ..userRepeat = (a['reconsumeCount'] as num?)?.toInt() ?? 0
    ..notes = a['notes'] as String?
    ..isListPrivate = a['private'] == true
    ..userStartedAt = parseKitsuDate(a['startedAt'])
    ..userCompletedAt = parseKitsuDate(a['finishedAt'])
    ..userListId = int.tryParse('${entry['id']}')
    ..userUpdatedAt = kitsuEpoch(a['progressedAt'] ?? a['updatedAt']);
}

List<Media> mapKitsuLibrary(JsonApi doc) {
  final out = <Media>[];
  for (final entry in doc.data) {
    final node = doc.one(entry, 'media');
    if (node == null) continue;
    final media = mapKitsuMedia(node);
    applyKitsuEntry(media, entry);
    out.add(media);
  }
  return out;
}

String? _personImage(Map<String, dynamic> a) => kitsuImage(a['image']);

Author mapKitsuPerson(Map<String, dynamic> node, {String? role}) {
  final a = attrs(node);
  return Author(
    id: '${node['id']}',
    name: a['name'] as String?,
    image: _personImage(a),
    role: role,
  );
}

Character mapKitsuCharacter(
  Map<String, dynamic> node, {
  String? role,
  List<Author> voices = const [],
}) {
  final a = attrs(node);
  return Character(
    id: '${node['id']}',
    name: (a['canonicalName'] ?? a['name']) as String?,
    image: _personImage(a),
    role: role == null ? null : _titleCase(role),
    voiceActor: voices,
  );
}

List<Character> mapKitsuCast(JsonApi doc) {
  final out = <Character>[];
  for (final entry in doc.data) {
    final character = doc.one(entry, 'character');
    if (character == null) continue;
    final voices = <Author>[];
    for (final casting in doc.many(entry, 'castings')) {
      if (attrs(casting)['locale'] != 'ja') continue;
      final person = doc.one(casting, 'person');
      if (person != null) voices.add(mapKitsuPerson(person));
    }
    out.add(
      mapKitsuCharacter(
        character,
        role: attrs(entry)['role'] as String?,
        voices: voices,
      ),
    );
  }
  return out;
}

List<Author> mapKitsuStaff(JsonApi doc) => [
  for (final entry in doc.data)
    if (doc.one(entry, 'person') case final person?)
      mapKitsuPerson(person, role: attrs(entry)['role'] as String?),
];

String kitsuHtml(String? text) => (text ?? '').trim().replaceAll('\n', '<br>');

Review? mapKitsuReview(JsonApi doc, Map<String, dynamic> node, String mediaId) {
  final a = attrs(node);
  if (a['spoiler'] == true) return null;
  final body = (a['contentFormatted'] ?? a['content']) as String?;
  if (body == null || body.trim().isEmpty) return null;
  final user = doc.one(node, 'user');
  final ua = user == null ? const <String, dynamic>{} : attrs(user);
  final rating = double.tryParse('${a['rating']}');
  final likes = int.tryParse('${a['likesCount']}');
  return Review(
    id: int.parse('${node['id']}'),
    mediaId: 0,
    mediaType: mediaId,
    body: body.trim(),
    rating: likes,
    ratingAmount: likes,
    score: rating == null ? null : (rating * 10).round(),
    siteUrl: 'https://kitsu.io/reviews/${node['id']}',
    createdAt: kitsuEpoch(a['createdAt']),
    user: user == null
        ? null
        : User(
            id: int.tryParse('${user['id']}') ?? 0,
            name: ua['name'] as String? ?? '',
            pfp: kitsuImage(ua['avatar'], const ['medium', 'large', 'small']),
          ),
  );
}

MediaReaction? mapKitsuReaction(JsonApi doc, Map<String, dynamic> node) {
  final a = attrs(node);
  final text = (a['reaction'] as String?)?.trim() ?? '';
  if (text.isEmpty || a['heldReason'] != null) return null;
  final user = doc.one(node, 'user');
  final ua = user == null ? const <String, dynamic>{} : attrs(user);
  return MediaReaction(
    id: '${node['id']}',
    text: text,
    votes: (a['upVotesCount'] as num?)?.toInt() ?? 0,
    createdAt: kitsuEpoch(a['createdAt']),
    user: user == null
        ? null
        : User(
            id: int.tryParse('${user['id']}') ?? 0,
            name: ua['name'] as String? ?? '',
            pfp: kitsuImage(ua['avatar'], const ['medium', 'large', 'small']),
          ),
  );
}
