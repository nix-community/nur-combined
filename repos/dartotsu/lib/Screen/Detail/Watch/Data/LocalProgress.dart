import 'Media/MediaRecord.dart';
import 'EpisodeUnits.dart';

double? partialFraction(Playback? playback) {
  if (playback == null || playback.duration <= 0 || playback.position <= 0) {
    return null;
  }
  return playback.finished ? null : playback.fraction.clamp(0.0, 1.0);
}

int effectiveProgress(
  int service,
  Iterable<WatchUnit> units,
  Map<String, Playback> playback,
) {
  var best = service;
  for (final unit in units) {
    final saved = playback[unit.slot];
    if (saved == null || !saved.finished) continue;
    final value = unit.value.floor();
    if (value > best) best = value;
  }
  return best;
}
