import '../../NetworkManager/NetworkManager.dart';
import '../../State/State.dart';

enum TrendzChart {
  anime('top-anime'),
  female('female-characters'),
  male('male-characters'),
  couple('couple-ship');

  final String slug;

  const TrendzChart(this.slug);
}

class TrendzEntry {
  final int position;
  final int previously;
  final int peak;
  final int weeks;
  final int votes;
  final String name;
  final String sub;
  final String? image;

  const TrendzEntry({
    required this.position,
    this.previously = 0,
    this.peak = 0,
    this.weeks = 0,
    this.votes = 0,
    required this.name,
    this.sub = '',
    this.image,
  });

  int? get change => previously > 0 ? previously - position : null;

  bool get isNew => previously == 0 && weeks <= 1;
}

class TrendzWeek {
  final String name;
  final String season;
  final String week;
  final String date;
  final int votes;
  final List<TrendzEntry> entries;

  const TrendzWeek({
    required this.name,
    this.season = '',
    this.week = '',
    this.date = '',
    this.votes = 0,
    this.entries = const [],
  });
}

TrendzWeek? parseTrendz(Object? json) {
  if (json is! List || json.isEmpty || json.first is! Map) return null;
  final chart = json.first as Map;
  final entries = <TrendzEntry>[];
  for (final c in (chart['choices'] as List? ?? const [])) {
    if (c is! Map) continue;
    final images = c['images'] is Map ? c['images'] as Map : const {};
    entries.add(
      TrendzEntry(
        position: (c['position'] as num?)?.toInt() ?? 0,
        previously: (c['previously'] as num?)?.toInt() ?? 0,
        peak: (c['peak'] as num?)?.toInt() ?? 0,
        weeks: (c['weeksAtTopTen'] as num?)?.toInt() ?? 0,
        votes: (c['total'] as num?)?.toInt() ?? 0,
        name: '${c['name'] ?? ''}',
        sub: '${c['subText'] ?? c['nameAlt'] ?? ''}',
        image:
            (images['medium'] ?? images['large'] ?? images['small']) as String?,
      ),
    );
  }
  entries.sort((a, b) => a.position.compareTo(b.position));
  return TrendzWeek(
    name: '${chart['name'] ?? ''}',
    season: '${chart['season'] ?? ''}',
    week: '${chart['week'] ?? ''}',
    date: '${chart['date'] ?? ''}',
    votes: (chart['votes'] as num?)?.toInt() ?? 0,
    entries: entries,
  );
}

class AniTrendz {
  AniTrendz._();

  static const _base =
      'https://us-central1-anitrendz-prod.cloudfunctions.net/'
      'animeTrendingAPI/charts';
  static final _cache = <TrendzChart, (DateTime, TrendzWeek)>{};

  static Future<TrendzWeek> chart(
    TrendzChart chart, {
    bool force = false,
  }) async {
    final cached = _cache[chart];
    if (!force &&
        cached != null &&
        DateTime.now().difference(cached.$1) < const Duration(hours: 1)) {
      return cached.$2;
    }
    final res = await find<NetworkManager>().get('$_base/${chart.slug}');
    if (!res.isOk) throw StateError('AniTrendz HTTP ${res.statusCode}');
    final week = parseTrendz(res.data);
    if (week == null) throw StateError('AniTrendz returned no chart');
    _cache[chart] = (DateTime.now(), week);
    return week;
  }
}
