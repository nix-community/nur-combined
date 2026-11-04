import '../../../../../Logger.dart';
import '../../../../../Api/Services/Simkl/Auth.dart';
import '../../../../../Core/State/State.dart';
import '../EpisodeMeta.dart';
import 'MetaHttp.dart';

class SimklEpisodesProvider extends EpisodeMetaProvider {
  @override
  String get id => 'simkl';

  @override
  String get name => 'Simkl';

  @override
  bool supports(MetaIds ids) => ids.anime && ids.simkl != null;

  @override
  Future<Map<String, EpisodeMeta>> fetch(MetaIds ids) async {
    final dynamic body;
    try {
      body = await find<SimklAuth>().client.get(
        '/anime/episodes/${ids.simkl}',
        query: {'extended': 'full'},
        auth: false,
      );
    } catch (e, st) {
      logError('Simkl', e, st);
      return const {};
    }
    if (body is! List) return const {};
    final out = <String, EpisodeMeta>{};
    for (final ep in body) {
      if (ep is! Map || ep['type'] != 'episode' || ep['episode'] == null) {
        continue;
      }
      final key = episodeKey(ep['episode']);
      final image = nonBlank(ep['img']);
      out[key] = EpisodeMeta(
        number: key,
        title: nonBlank(ep['title']),
        description: nonBlank(ep['description']),
        thumbnail: image == null
            ? null
            : 'https://wsrv.nl/?url=https://simkl.in/episodes/${image}_c.webp',
        aired: DateTime.tryParse('${ep['date'] ?? ep['aired'] ?? ''}'),
      );
    }
    return out;
  }
}
