import '../../../../Core/Services/Model/Author.dart';
import '../../../../Core/Services/Model/Character.dart';
import '../../../../Core/Services/Model/Media.dart';
import 'Mapper.dart';

const _views = 'views(names: ["large", "medium", "small"]) { name url }';

String kitsuDetailQuery(bool anime, {required bool withEntry}) {
  final root = anime ? 'findAnimeById' : 'findMangaById';
  final kindFields = anime
      ? 'episodeCount episodeLength'
      : 'chapterCount volumeCount';
  final trailer = anime ? 'youtubeTrailerVideoId' : '';
  final animeOnly = anime
      ? '''
    productions(first: 10) { nodes { role company { id name } } }
    streamingLinks(first: 10) { nodes { url streamer { siteName } } }'''
      : '';
  final entry = withEntry
      ? '''
    myLibraryEntry {
      id status progress rating notes private reconsumeCount reconsuming
      startedAt finishedAt progressedAt updatedAt
    }'''
      : '';
  return '''
query Detail(\$id: ID!) {
  $root(id: \$id) {
    id slug sfw ageRating ageRatingGuide status subtype startDate endDate
    averageRating averageRatingRank userCount userCountRank favoritesCount
    $kindFields
    $trailer
    titles { canonical alternatives original originalLocale romanized translated translatedLocale localized(locales: ["en", "en_us", "en_jp", "ja_jp"]) }
    description(locales: ["en"])
    posterImage { $_views }
    bannerImage { $_views }
    categories(first: 20) { nodes { slug isNsfw title(locales: ["en"]) } }
    relationships(first: 100) {
      nodes {
        kind
        destination {
          __typename id slug sfw status averageRating
          titles { canonical localized(locales: ["en", "en_jp"]) }
          posterImage { $_views }
        }
      }
    }$animeOnly
    characters(first: 20, sort: [{on: ROLE, direction: DESCENDING}]) {
      nodes {
        role
        character { id names { canonical } image { $_views } }
        voices(first: 3, locale: "ja_jp") { nodes { person { id name image { $_views } } } }
      }
    }
    staff(first: 20) { nodes { role person { id name image { $_views } } } }$entry
  }
}''';
}

class KitsuGraphDetail {
  final Media media;
  final List<Character> characters;
  final List<Author> staff;

  KitsuGraphDetail(this.media, this.characters, this.staff);
}

Map<String, String>? _image(Object? image) {
  if (image is! Map) return null;
  final out = <String, String>{};
  for (final v in (image['views'] as List?) ?? const []) {
    if (v is Map && v['name'] is String && v['url'] is String) {
      out[v['name'] as String] = v['url'] as String;
    }
  }
  return out.isEmpty ? null : out;
}

List<Map> _nodes(Object? connection) {
  final list = connection is Map ? connection['nodes'] : null;
  return [
    if (list is List)
      for (final n in list)
        if (n is Map) n,
  ];
}

String? _lower(Object? v) => v is String ? v.toLowerCase() : null;

Map<String, dynamic> _titles(Object? titles) {
  if (titles is! Map) return const {};
  final localized = (titles['localized'] as Map?) ?? const {};
  final out = <String, dynamic>{
    for (final e in localized.entries) '${e.key}': e.value,
  };
  final translated = titles['translated'];
  if (translated is String &&
      '${titles['translatedLocale']}'.toLowerCase().startsWith('en')) {
    out.putIfAbsent('en', () => translated);
  }
  final romanized = titles['romanized'];
  if (romanized is String) out.putIfAbsent('en_jp', () => romanized);
  final original = titles['original'];
  if (original is String &&
      '${titles['originalLocale']}'.toLowerCase().startsWith('ja')) {
    out.putIfAbsent('ja_jp', () => original);
  }
  return out;
}

Map<String, dynamic> _mediaAttrs(Map node, {required bool anime}) {
  final titles = node['titles'] as Map?;
  final description = node['description'];
  return {
    'slug': node['slug'],
    'canonicalTitle': titles?['canonical'],
    'titles': _titles(titles),
    'abbreviatedTitles': titles?['alternatives'],
    'synopsis': description is Map
        ? (description['en'] ?? description.values.firstOrNull)
        : description,
    'averageRating': node['averageRating'],
    'ratingRank': node['averageRatingRank'],
    'userCount': node['userCount'],
    'popularityRank': node['userCountRank'],
    'favoritesCount': node['favoritesCount'],
    'nsfw': node['sfw'] == false,
    'ageRating': node['ageRating'],
    'ageRatingGuide': node['ageRatingGuide'],
    'status': _lower(node['status']),
    'subtype': _lower(node['subtype']),
    'startDate': node['startDate'],
    'endDate': node['endDate'],
    'episodeCount': node['episodeCount'],
    'episodeLength': node['episodeLength'],
    'chapterCount': node['chapterCount'],
    'volumeCount': node['volumeCount'],
    'youtubeVideoId': node['youtubeTrailerVideoId'],
    'posterImage': _image(node['posterImage']),
    'coverImage': _image(node['bannerImage']),
  };
}

Map<String, dynamic> _ref(String type, Object id) => {
  'data': {'type': type, 'id': '$id'},
};

Map<String, dynamic> _refs(String type, Iterable<Object> ids) => {
  'data': [
    for (final id in ids) {'type': type, 'id': '$id'},
  ],
};

KitsuGraphDetail? parseKitsuGraphDetail(
  Map<String, dynamic> body, {
  required bool anime,
}) {
  final data = body['data'];
  final node = data is Map
      ? data[anime ? 'findAnimeById' : 'findMangaById']
      : null;
  if (node is! Map) return null;
  final kind = anime ? 'anime' : 'manga';
  final included = <Map<String, dynamic>>[];

  final categoryIds = <String>[];
  for (final c in _nodes(node['categories'])) {
    final title = c['title'];
    final text = title is Map ? title['en'] : title;
    if (text is! String || categoryIds.contains('${c['slug']}')) continue;
    categoryIds.add('${c['slug']}');
    included.add({
      'type': 'categories',
      'id': '${c['slug']}',
      'attributes': {'title': text, 'nsfw': c['isNsfw'] == true},
    });
  }

  final relationIds = <String>[];
  for (final (i, r) in _nodes(node['relationships']).indexed) {
    final dest = r['destination'];
    if (dest is! Map) continue;
    final destType = '${dest['__typename']}'.toLowerCase() == 'manga'
        ? 'manga'
        : 'anime';
    final destKey = '$destType-${dest['id']}';
    included.add({
      'type': destType,
      'id': '${dest['id']}',
      'attributes': _mediaAttrs(dest, anime: destType == 'anime'),
    });
    included.add({
      'type': 'mediaRelationships',
      'id': 'rel-$i-$destKey',
      'attributes': {'role': _lower(r['kind'])},
      'relationships': {'destination': _ref(destType, dest['id'] as Object)},
    });
    relationIds.add('rel-$i-$destKey');
  }

  final productionIds = <String>[];
  for (final (i, p) in _nodes(node['productions']).indexed) {
    final company = p['company'];
    if (company is! Map) continue;
    included.add({
      'type': 'producers',
      'id': '${company['id']}',
      'attributes': {'name': company['name']},
    });
    included.add({
      'type': 'animeProductions',
      'id': 'prod-$i',
      'attributes': {'role': _lower(p['role'])},
      'relationships': {'producer': _ref('producers', company['id'] as Object)},
    });
    productionIds.add('prod-$i');
  }

  final linkIds = <String>[];
  for (final (i, l) in _nodes(node['streamingLinks']).indexed) {
    final streamer = l['streamer'];
    included.add({
      'type': 'streamingLinks',
      'id': 'link-$i',
      'attributes': {'url': l['url']},
      'relationships': {
        if (streamer is Map) 'streamer': _ref('streamers', 'link-$i'),
      },
    });
    if (streamer is Map) {
      included.add({
        'type': 'streamers',
        'id': 'link-$i',
        'attributes': {'siteName': streamer['siteName']},
      });
    }
    linkIds.add('link-$i');
  }

  final mediaNode = <String, dynamic>{
    'type': kind,
    'id': '${node['id']}',
    'attributes': _mediaAttrs(node, anime: anime),
    'relationships': {
      'categories': _refs('categories', categoryIds),
      'mediaRelationships': _refs('mediaRelationships', relationIds),
      'animeProductions': _refs('animeProductions', productionIds),
      'streamingLinks': _refs('streamingLinks', linkIds),
    },
  };
  final media = mapKitsuMedia(
    mediaNode,
    doc: JsonApi({'data': mediaNode, 'included': included}),
  );

  final entry = node['myLibraryEntry'];
  if (entry is Map) {
    applyKitsuEntry(media, {
      'id': entry['id'],
      'attributes': {
        'status': _lower(entry['status']),
        'reconsuming': entry['reconsuming'],
        'ratingTwenty': entry['rating'],
        'progress': entry['progress'],
        'reconsumeCount': entry['reconsumeCount'],
        'notes': entry['notes'],
        'private': entry['private'],
        'startedAt': entry['startedAt'],
        'finishedAt': entry['finishedAt'],
        'progressedAt': entry['progressedAt'],
        'updatedAt': entry['updatedAt'],
      },
    });
  }

  return KitsuGraphDetail(media, _cast(node, kind), _staff(node, kind));
}

List<Character> _cast(Map node, String kind) {
  final entries = <Map<String, dynamic>>[];
  final included = <Map<String, dynamic>>[];
  for (final (i, c) in _nodes(node['characters']).indexed) {
    final character = c['character'];
    if (character is! Map) continue;
    final names = character['names'] as Map?;
    included.add({
      'type': 'characters',
      'id': '${character['id']}',
      'attributes': {
        'canonicalName': names?['canonical'],
        'image': _image(character['image']),
      },
    });
    final castingIds = <String>[];
    for (final (j, v) in _nodes(c['voices']).indexed) {
      final person = v['person'];
      if (person is! Map) continue;
      included
        ..add({
          'type': 'people',
          'id': '${person['id']}',
          'attributes': {
            'name': person['name'],
            'image': _image(person['image']),
          },
        })
        ..add({
          'type': 'castings',
          'id': 'cast-$i-$j',
          'attributes': {'locale': 'ja'},
          'relationships': {'person': _ref('people', person['id'] as Object)},
        });
      castingIds.add('cast-$i-$j');
    }
    entries.add({
      'type': '${kind}Characters',
      'id': 'entry-$i',
      'attributes': {'role': _lower(c['role'])},
      'relationships': {
        'character': _ref('characters', character['id'] as Object),
        'castings': _refs('castings', castingIds),
      },
    });
  }
  return mapKitsuCast(JsonApi({'data': entries, 'included': included}));
}

List<Author> _staff(Map node, String kind) {
  final entries = <Map<String, dynamic>>[];
  final included = <Map<String, dynamic>>[];
  for (final (i, s) in _nodes(node['staff']).indexed) {
    final person = s['person'];
    if (person is! Map) continue;
    included.add({
      'type': 'people',
      'id': '${person['id']}',
      'attributes': {'name': person['name'], 'image': _image(person['image'])},
    });
    entries.add({
      'type': '${kind}Staff',
      'id': 'staff-$i',
      'attributes': {'role': s['role']},
      'relationships': {'person': _ref('people', person['id'] as Object)},
    });
  }
  return mapKitsuStaff(JsonApi({'data': entries, 'included': included}));
}
