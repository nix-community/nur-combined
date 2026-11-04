import '../../../../../Logger.dart';
import '../../../../../Api/Services/MyAnimeList/Auth.dart';
import '../EpisodeMeta.dart';
import 'MetaHttp.dart';

Map<String, EpisodeMeta> _parse(
  Iterable<dynamic> rows,
  Map<String, EpisodeMeta> into,
) {
  for (final row in rows) {
    if (row is! Map || row['mal_id'] == null) continue;
    final key = episodeKey(row['mal_id']);
    into[key] = EpisodeMeta(
      number: key,
      title: nonBlank(row['title']),
      filler: row['filler'] as bool?,
      recap: row['recap'] as bool?,
      aired: DateTime.tryParse('${row['aired'] ?? ''}'),
      rating: (row['score'] as num?)?.toDouble(),
    );
  }
  return into;
}

class TenraiProvider extends EpisodeMetaProvider {
  @override
  String get id => 'tenrai';

  @override
  String get name => 'Tenrai';

  @override
  bool supports(MetaIds ids) => ids.anime && ids.mal != null;

  @override
  Future<Map<String, EpisodeMeta>> fetch(MetaIds ids) async {
    final out = <String, EpisodeMeta>{};
    final tenrai = malAuth.tenrai;
    for (var page = 1; page <= 40; page++) {
      final Map<String, dynamic> body;
      try {
        body = await tenrai.get(
          '/anime/${ids.mal}/episodes',
          query: {'page': '$page'},
          cache: const Duration(hours: 1),
        );
      } catch (e, st) {
        logError('Tenrai', e, st);
        break;
      }
      final rows = body['data'];
      if (rows is! List || rows.isEmpty) break;
      _parse(rows, out);
      final pagination = body['pagination'];
      if (pagination is! Map || pagination['has_next_page'] != true) break;
    }
    return out;
  }
}
