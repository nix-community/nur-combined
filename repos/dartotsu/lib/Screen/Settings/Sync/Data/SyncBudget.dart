import 'SyncModels.dart';

class SyncBudget {
  static const _maxBackoff = Duration(minutes: 15);

  final Map<String, List<int>> stamps;
  final _holds = <String, DateTime>{};
  final _strikes = <String, int>{};

  SyncBudget([Map<String, List<int>>? stamps]) : stamps = stamps ?? {};

  void stamp(String id, int count, {DateTime? now}) {
    final at = (now ?? DateTime.now()).millisecondsSinceEpoch;
    final day = at - const Duration(days: 1).inMilliseconds;
    (stamps[id] ??= [])
      ..removeWhere((s) => s < day)
      ..addAll(List.filled(count, at));
  }

  void hold(String id, Duration retryAfter, {DateTime? now}) {
    final strikes = _strikes[id] = (_strikes[id] ?? 0) + 1;
    final backoff = Duration(seconds: 30 * (1 << (strikes - 1).clamp(0, 5)));
    final wait = retryAfter > backoff ? retryAfter : backoff;
    _holds[id] = (now ?? DateTime.now()).add(
      wait > _maxBackoff ? _maxBackoff : wait,
    );
  }

  void succeeded(String id) => _strikes.remove(id);

  Duration waitFor(
    String id,
    List<SyncLimit> limits,
    int perBatch, {
    DateTime? now,
  }) {
    final at = now ?? DateTime.now();
    var until = _holds[id];
    if (until != null && !until.isAfter(at)) {
      _holds.remove(id);
      until = null;
    }
    final list = [...?stamps[id]]..sort();
    for (final limit in limits) {
      final from = at.millisecondsSinceEpoch - limit.per.inMilliseconds;
      final inside = list.where((s) => s > from).toList();
      final excess = inside.length + perBatch - limit.requests;
      if (excess <= 0) continue;
      final free = DateTime.fromMillisecondsSinceEpoch(
        inside[(excess - 1).clamp(0, inside.length - 1)] +
            limit.per.inMilliseconds,
      );
      if (until == null || free.isAfter(until)) until = free;
    }
    if (until == null) return Duration.zero;
    final left = until.difference(at);
    return left.isNegative
        ? Duration.zero
        : left + const Duration(milliseconds: 50);
  }

  int usedIn(String id, SyncLimit limit, {DateTime? now}) {
    final from =
        (now ?? DateTime.now()).millisecondsSinceEpoch -
        limit.per.inMilliseconds;
    return (stamps[id] ?? const <int>[]).where((s) => s > from).length;
  }
}
