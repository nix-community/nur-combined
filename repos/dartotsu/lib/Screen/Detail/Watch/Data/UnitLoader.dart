import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:flutter/foundation.dart';

import '../../../../Logger.dart';
import '../../../../Core/Services/MediaService.dart';
import '../../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../../Core/Services/Model/Media.dart';
import 'EpisodeUnits.dart';
import 'SourceMatcher.dart';

String playTitleOf(WatchUnit unit) {
  final label = getString.watchEpisodeNumber(unit.number);
  return unit.title.isEmpty || unit.title == label
      ? label
      : '$label: ${unit.title}';
}

Future<List<WatchUnit>?> loadUnits({
  required MediaService service,
  required Media media,
  required Source source,
  String? season,
}) async {
  try {
    final target = media.sourceData != null
        ? DMedia.withUrl(media.shareLink)
        : SourceMatcher.saved(service, source, media);
    if (target == null) return null;
    final detail = await source.methods.getDetail(target);
    final raw = detail.episodes ?? const <DEpisode>[];
    if (raw.isEmpty) return null;
    final anime = media.isAnime;
    final normalized = !anime
        ? prepareChapters(raw, media.mainName)
        : raw.length < 50
        ? normalizeAll(raw)
        : await compute(normalizeIsolate, raw);
    final seasoned = anime && seasonNames(normalized).isNotEmpty;
    return buildUnits(
      seasoned && season != null
          ? [
              for (final e in normalized)
                if (seasonOf(e) == season.trim()) e,
            ]
          : normalized,
      const {},
      fallbackThumb: media.banner ?? media.cover ?? '',
      anime: anime,
      seasoned: seasoned,
      seasonOffsets: seasoned && service.seriesProgress
          ? seasonOffsets(normalized, seasonNames(normalized))
          : const {},
    );
  } catch (e) {
    logger('Resume units failed: $e', tag: 'RESUME');
    return null;
  }
}
