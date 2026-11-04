part of '../Queries.dart';

const _missingSequelTitle = 'Missing Sequel';
const _missingSequelTtl = Duration(days: 1);
const _missingSequelCap = 60;

const _ownedQuery = r'''
query ($userId: Int, $chunk: Int) {
  MediaListCollection(userId: $userId, type: ANIME, chunk: $chunk, perChunk: 500) {
    hasNextChunk
    lists {
      entries {
        status
        media {
          id
          relations {
            edges {
              relationType(version: 2)
              node { id type }
            }
          }
        }
      }
    }
  }
}
''';

const _sequelMediaQuery =
    '''
query (\$ids: [Int], \$page: Int) {
  Page(page: \$page, perPage: 50) {
    pageInfo { hasNextPage }
    media(id_in: \$ids, type: ANIME, sort: POPULARITY_DESC) { $anilistMediaFragment }
  }
}
''';

extension on AnilistQueries {
  String _missingKey(int userId) => 'anilistMissingSequel/$userId';

  List<Media>? _readMissing(int userId, {required bool anyAge}) {
    final raw = loadCustomData<Map<String, dynamic>>(
      _missingKey(userId),
      location: PrefLocation.CACHE,
    );
    if (raw == null) return null;
    final at = DateTime.fromMillisecondsSinceEpoch(
      (raw['at'] as num?)?.toInt() ?? 0,
    );
    if (!anyAge && DateTime.now().difference(at) > _missingSequelTtl) {
      return null;
    }
    try {
      return [
        for (final m in (raw['media'] as List? ?? const []))
          Media.fromJson(Map<String, dynamic>.from(m as Map)),
      ];
    } catch (e, st) {
      logError('Queries', e, st);
      return null;
    }
  }

  SectionJob _missingSequelJob(int userId) => () async {
    final force = SectionReload.manual;
    if (!force) {
      final fresh = _readMissing(userId, anyAge: false);
      if (fresh != null) {
        return fresh.isEmpty ? {} : {_missingSequelTitle: fresh};
      }
    }
    try {
      final media = await _fetchMissingSequels(userId);
      saveCustomData<Map<String, dynamic>>(_missingKey(userId), {
        'at': DateTime.now().millisecondsSinceEpoch,
        'media': [for (final m in media) jsonDecode(jsonEncode(m.toJson()))],
      }, location: PrefLocation.CACHE);
      return media.isEmpty ? {} : {_missingSequelTitle: media};
    } catch (e, st) {
      logError('Queries', e, st);
      final stale = _readMissing(userId, anyAge: true);
      if (stale == null) rethrow;
      return stale.isEmpty ? {} : {_missingSequelTitle: stale};
    }
  };

  Future<List<Media>> _fetchMissingSequels(int userId) async {
    final owned = <int>{};
    final sequels = <int>{};
    for (var chunk = 1; chunk <= 20; chunk++) {
      final body = await client.queryRaw(
        _ownedQuery,
        variables: {'userId': userId, 'chunk': chunk},
      );
      final part = await compute(parseSequelOwnership, body);
      owned.addAll(part.owned);
      sequels.addAll(part.sequels);
      if (!part.hasNext) break;
    }
    final missing = sequels.difference(owned).toList();
    if (missing.isEmpty) return const [];
    final hideAdult = !AnilistPref.displayAdult.value;
    final found = <Media>[];
    for (var page = 1; page <= 3 && found.length < _missingSequelCap; page++) {
      final data = await client.query(
        _sequelMediaQuery,
        variables: {'ids': missing, 'page': page},
      );
      final result = data['Page'] as Map<String, dynamic>?;
      for (final m in (result?['media'] as List?) ?? const []) {
        final media = mapAnilistMedia((m as Map).cast<String, dynamic>());
        if (media.status == 'CANCELLED' || (hideAdult && media.isAdult)) {
          continue;
        }
        found.add(media);
      }
      final next = (result?['pageInfo'] as Map?)?['hasNextPage'] == true;
      if (!next) break;
    }
    return found.take(_missingSequelCap).toList();
  }
}

class SequelOwnership {
  final Set<int> owned;
  final Set<int> sequels;
  final bool hasNext;

  const SequelOwnership(this.owned, this.sequels, this.hasNext);
}

SequelOwnership parseSequelOwnership(String body) {
  final data = anilistData(body);
  final collection = data['MediaListCollection'] as Map<String, dynamic>?;
  final owned = <int>{};
  final sequels = <int>{};
  for (final list in (collection?['lists'] as List?) ?? const []) {
    for (final entry in ((list as Map)['entries'] as List?) ?? const []) {
      final media = (entry as Map)['media'] as Map?;
      final id = (media?['id'] as num?)?.toInt();
      if (id == null) continue;
      owned.add(id);
      if (entry['status'] != 'COMPLETED') continue;
      final edges = (media?['relations'] as Map?)?['edges'] as List?;
      for (final edge in edges ?? const []) {
        final node = (edge as Map)['node'] as Map?;
        if (edge['relationType'] != 'SEQUEL' || node?['type'] != 'ANIME') {
          continue;
        }
        final sequel = (node?['id'] as num?)?.toInt();
        if (sequel != null) sequels.add(sequel);
      }
    }
  }
  return SequelOwnership(owned, sequels, collection?['hasNextChunk'] == true);
}
