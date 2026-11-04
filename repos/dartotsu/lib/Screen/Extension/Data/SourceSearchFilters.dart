import 'package:dartotsu_extension_bridge/Models/SourceFilter.dart';
import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';

import '../../../Core/Preferences/PrefManager.dart';

class SourceSearchFilters {
  SourceSearchFilters._();

  static String _key(Source source) => 'sourceSearchFilters/${source.id}';

  static List<SourceFilter>? saved(Source source) {
    final raw = PrefManager.getCustomVal<Map>(_key(source));
    final list = raw?['filters'];
    if (list is! List) return null;
    try {
      return [
        for (final f in list)
          SourceFilter.fromJson(Map<String, dynamic>.from(f as Map)),
      ];
    } catch (_) {
      return null;
    }
  }

  static List<Map<String, dynamic>> json(Source source) => [
    for (final f in saved(source) ?? const <SourceFilter>[]) f.toJson(),
  ];

  static void save(Source source, List<SourceFilter> filters) {
    PrefManager.setCustomVal<Map>(_key(source), {
      'filters': [for (final f in filters) f.toJson()],
    });
  }

  static void clear(Source source) => PrefManager.removeCustomVal(_key(source));
}
