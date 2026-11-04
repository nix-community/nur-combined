import '../EpisodeMeta.dart';
import 'MetaHttp.dart';

class KitsuEpisodesProvider extends EpisodeMetaProvider {
  @override
  String get id => 'kitsu';

  @override
  String get name => 'Kitsu';

  @override
  bool supports(MetaIds ids) =>
      ids.anime && (ids.anilist != null || ids.mal != null);

  @override
  Future<Map<String, EpisodeMeta>> fetch(MetaIds ids) async {
    final id = ids.anilist ?? ids.mal;
    final site = ids.anilist != null ? 'ANILIST_ANIME' : 'MYANIMELIST_ANIME';
    final query =
        '''
query {
  lookupMapping(externalId: $id, externalSite: $site) {
    __typename
    ... on Anime {
      id
      episodes(first: 2000) {
        nodes {
          number
          titles { canonical }
          description
          thumbnail { original { url } }
          length
        }
      }
    }
  }
}''';
    final body = await metaPost('https://kitsu.io/api/graphql', {
      'query': query,
    });
    if (body is! Map) return const {};
    final mapping = body['data']?['lookupMapping'];
    if (mapping is! Map) return const {};
    ids.kitsu ??= int.tryParse('${mapping["id"]}');
    final nodes = mapping['episodes']?['nodes'];
    if (nodes is! List) return const {};
    final out = <String, EpisodeMeta>{};
    for (final node in nodes) {
      if (node is! Map || node['number'] == null) continue;
      final key = episodeKey(node['number']);
      final description = node['description'];
      out[key] = EpisodeMeta(
        number: key,
        title: nonBlank(node['titles']?['canonical']),
        description: nonBlank(
          description is Map ? description['en'] : description,
        ),
        thumbnail: nonBlank(node['thumbnail']?['original']?['url']),
        runtime: (node['length'] as num?)?.toInt(),
      );
    }
    return out;
  }
}
