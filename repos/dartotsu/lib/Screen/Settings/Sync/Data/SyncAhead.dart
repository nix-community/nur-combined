import 'SyncModels.dart';

const syncAheadId = 'ahead';

int _statusRank(String? status) => switch (status) {
  'COMPLETED' => 5,
  'REPEATING' => 4,
  'CURRENT' => 3,
  'PAUSED' => 2,
  'DROPPED' => 1,
  _ => 0,
};

int _effectiveProgress(SyncItem i) {
  final total = i.total ?? 0;
  return i.status == 'COMPLETED' && total > i.progress ? total : i.progress;
}

int compareAhead(SyncItem a, SyncItem b) {
  final steps = [
    _effectiveProgress(a).compareTo(_effectiveProgress(b)),
    _statusRank(a.status).compareTo(_statusRank(b.status)),
    a.repeat.compareTo(b.repeat),
    (a.score > 0 ? 1 : 0).compareTo(b.score > 0 ? 1 : 0),
  ];
  return steps.firstWhere((c) => c != 0, orElse: () => 0);
}

List<SyncItem> mergeAhead(
  List<(String, List<SyncItem>)> libraries, {
  bool shareScore = true,
}) {
  final groups = <List<(String, SyncItem)>>[];
  final index = <String, List<(String, SyncItem)>>{};
  for (final (service, items) in libraries) {
    for (final item in items) {
      List<(String, SyncItem)>? group;
      for (final e in item.ids.entries) {
        final hit = index['${e.key}:${e.value}'];
        if (hit != null && hit.every((m) => m.$1 != service)) {
          group = hit;
          break;
        }
      }
      if (group == null) {
        group = [];
        groups.add(group);
      }
      group.add((service, item));
      for (final e in item.ids.entries) {
        index.putIfAbsent('${e.key}:${e.value}', () => group!);
      }
    }
  }
  return [
    for (final group in groups)
      () {
        var best = group.first;
        for (final m in group.skip(1)) {
          if (compareAhead(m.$2, best.$2) > 0) best = m;
        }
        final ids = <String, int>{...best.$2.ids};
        var score = best.$2.score;
        for (final m in group) {
          for (final e in m.$2.ids.entries) {
            ids.putIfAbsent(e.key, () => e.value);
          }
          if (shareScore && score == 0 && m.$2.score > 0) score = m.$2.score;
        }
        return best.$2.copy(
          id: '${best.$1}|${best.$2.id}',
          ids: ids,
          score: score,
          source: best.$1,
        );
      }(),
  ];
}
