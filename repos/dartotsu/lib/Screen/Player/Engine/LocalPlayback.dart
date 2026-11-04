import '../../Detail/Watch/Data/Media/MediaRecord.dart';
import '../../../Core/Preferences/PrefManager.dart';

const _key = 'localPlayback';
const _limit = 300;

class LocalPlayback {
  LocalPlayback._();

  static Map<String, Playback>? _cache;

  static Map<String, Playback> _load() {
    final cached = _cache;
    if (cached != null) return cached;
    final map = <String, Playback>{};
    final raw = PrefManager.getCustomVal<Map>(_key);
    for (final e in (raw ?? const {}).entries) {
      final item = Playback.fromJson(e.value);
      if (item != null) map['${e.key}'] = item;
    }
    return _cache = map;
  }

  static Playback? get(String key) => _load()[key];

  static void put(String key, Playback playback) {
    final map = _load();
    map[key] = playback;
    if (map.length > _limit) {
      final oldest = map.entries.toList()
        ..sort((a, b) => a.value.at.compareTo(b.value.at));
      for (final e in oldest.take(map.length - _limit)) {
        map.remove(e.key);
      }
    }
    PrefManager.setCustomVal<Map>(_key, {
      for (final e in map.entries) e.key: e.value.toJson(),
    });
  }
}
