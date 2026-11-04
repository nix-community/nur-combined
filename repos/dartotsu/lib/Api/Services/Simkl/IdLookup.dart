import 'package:rhttp/rhttp.dart';

final _target = RegExp(r'/(?:anime|tv|movies)/(\d+)');

Future<int?> simklIdFromRedirect({int? mal, int? anilist, int? kitsu}) async {
  final query = mal != null
      ? {'mal': '$mal'}
      : anilist != null
      ? {'anilist': '$anilist'}
      : kitsu != null
      ? {'kitsu': '$kitsu'}
      : null;
  if (query == null) return null;
  final res = await Rhttp.get(
    'https://api.simkl.com/redirect',
    query: {'to': 'simkl', ...query},
    settings: const ClientSettings(
      redirectSettings: RedirectSettings.none(),
      throwOnStatusCode: false,
    ),
  );
  final location = res.headerMapList['location']?.firstOrNull;
  final match = location == null ? null : _target.firstMatch(location);
  return int.tryParse(match?.group(1) ?? '');
}
