import 'SyncModels.dart';

class SyncMemory {
  final Map<String, int> resolved;
  final Set<String> ignored;
  final Map<String, int> fingerprints;
  final Map<String, int> fullAt;

  SyncMemory({
    Map<String, int>? resolved,
    Set<String>? ignored,
    Map<String, int>? fingerprints,
    Map<String, int>? fullAt,
  }) : resolved = resolved ?? {},
       ignored = ignored ?? {},
       fingerprints = fingerprints ?? {},
       fullAt = fullAt ?? {};

  static String resolveKey(
    String service,
    bool anime,
    int id, [
    String from = SyncKey.mal,
  ]) =>
      '$service|${anime ? 'a' : 'm'}|${from == SyncKey.mal ? '' : '$from:'}$id';

  static String ignoreKey(String service, bool anime, String mainId) =>
      '$service|${anime ? 'a' : 'm'}|$mainId';

  static String typeKey(String main, bool anime) =>
      '$main|${anime ? 'a' : 'm'}';

  int? native(
    String service,
    bool anime,
    int id, [
    String from = SyncKey.mal,
  ]) => resolved[resolveKey(service, anime, id, from)];

  void remember(
    String service,
    bool anime,
    int id,
    int native, [
    String from = SyncKey.mal,
  ]) => resolved[resolveKey(service, anime, id, from)] = native;

  bool isIgnored(String service, bool anime, String mainId) =>
      ignored.contains(ignoreKey(service, anime, mainId));

  void setIgnored(String service, bool anime, String mainId, bool value) {
    final key = ignoreKey(service, anime, mainId);
    value ? ignored.add(key) : ignored.remove(key);
  }

  Map<String, dynamic> toJson() => {
    'resolved': resolved,
    'ignored': ignored.toList(),
    'fingerprints': fingerprints,
    'fullAt': fullAt,
  };

  factory SyncMemory.fromJson(Map<dynamic, dynamic> j) {
    Map<String, int> ints(Object? v) => {
      if (v is Map)
        for (final e in v.entries) '${e.key}': (e.value as num).toInt(),
    };
    return SyncMemory(
      resolved: ints(j['resolved']),
      ignored: {for (final v in (j['ignored'] as List? ?? const [])) '$v'},
      fingerprints: ints(j['fingerprints']),
      fullAt: ints(j['fullAt']),
    );
  }
}
