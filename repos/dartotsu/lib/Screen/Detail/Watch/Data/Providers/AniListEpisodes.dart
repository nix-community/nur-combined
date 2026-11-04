import '../../../../../Logger.dart';
import '../../../../../Api/Services/Anilist/Auth.dart';
import '../EpisodeMeta.dart';
import 'MetaHttp.dart';

final _title = RegExp(
  r'^\s*(?:Episode|Ep\.?)\s*(\d+(?:\.\d+)?)\s*[-–:]?\s*(.*)$',
  caseSensitive: false,
);

class AniListEpisodesProvider extends EpisodeMetaProvider {
  @override
  String get id => 'anilist';

  @override
  String get name => 'AniList';

  @override
  bool supports(MetaIds ids) => ids.anime && ids.anilist != null;

  @override
  Future<Map<String, EpisodeMeta>> fetch(MetaIds ids) async {
    final Map<String, dynamic> data;
    try {
      data = await anilistAuth.client.query(
        '''
query (\$id: Int) {
  Media(id: \$id, type: ANIME) {
    streamingEpisodes { title thumbnail }
    airingSchedule(perPage: 150) { nodes { episode airingAt } }
  }
}''',
        variables: {'id': ids.anilist},
        useToken: false,
        showErrors: false,
      );
    } catch (e, st) {
      logError('AniListEpisodes', e, st);
      return const {};
    }
    final media = data['Media'];
    if (media is! Map) return const {};
    final out = <String, EpisodeMeta>{};
    final streaming = media['streamingEpisodes'];
    if (streaming is List) {
      for (final ep in streaming) {
        if (ep is! Map) continue;
        final match = _title.firstMatch('${ep['title'] ?? ''}');
        if (match == null) continue;
        final key = episodeKey(match.group(1));
        out[key] = EpisodeMeta(
          number: key,
          title: nonBlank(match.group(2)),
          thumbnail: nonBlank(ep['thumbnail']),
        );
      }
    }
    final nodes = media['airingSchedule']?['nodes'];
    if (nodes is List) {
      for (final node in nodes) {
        if (node is! Map || node['episode'] == null) continue;
        final key = episodeKey(node['episode']);
        final at = (node['airingAt'] as num?)?.toInt();
        final meta = out.putIfAbsent(key, () => EpisodeMeta(number: key));
        if (at != null) {
          meta.aired = DateTime.fromMillisecondsSinceEpoch(
            at * 1000,
            isUtc: true,
          );
        }
      }
    }
    return out;
  }
}
