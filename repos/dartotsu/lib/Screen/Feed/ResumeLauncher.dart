import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:flutter/widgets.dart';

import '../../Api/Services/Extension/Services.dart';
import '../../Core/Downloads/DownloadEngine.dart';
import '../../Core/Services/MediaService.dart';
import '../../Core/State/State.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Utils/Functions/SnackBar.dart';
import '../Detail/Watch/Data/EpisodeUnits.dart';
import '../Detail/Watch/Data/Media/ResumeStore.dart';
import '../Detail/Watch/Data/UnitLoader.dart';
import '../Player/Engine/PlayRequest.dart';
import '../Player/PlayerLauncher.dart';
import '../Reader/Engine/ReaderRequest.dart';
import '../Reader/ReaderLauncher.dart';
import 'FeedNavigation.dart';

Future<void> openResume(
  BuildContext context,
  MediaService service,
  ResumeEntry entry,
) async {
  final media = entry.buildMedia();
  final raw = entry.episode;
  final sourceId = entry.sourceId;
  if (raw == null || sourceId == null) {
    openDetail(context, service, media);
    return;
  }
  final type = entry.isWatch
      ? ItemType.anime
      : media.format?.toLowerCase() == 'novel'
      ? ItemType.novel
      : ItemType.manga;
  final saved = find<DownloadEngine>().hasLocalUnit(
    service.id,
    media.id,
    entry.unitKey,
  );
  var source = installedSourceById(sourceId);
  if (source == null && !saved) {
    await ensureSourcesReady(type);
    source = installedSourceById(sourceId);
  }
  if (!context.mounted) return;
  if (source == null && !saved) {
    snackString(getString.resumeSourceMissing);
    openDetail(context, service, media);
    return;
  }
  if (source != null && service.id == extensionServiceId) {
    media.sourceData = source;
  }
  final episode = DEpisode.fromJson(Map<String, dynamic>.from(raw));
  final src = source;
  openDetail(context, service, media, instant: true);
  if (entry.isWatch) {
    await openPlayer(
      PlayRequest(
        service: service,
        media: media,
        source: src,
        items: [
          PlayItem(
            key: entry.unitKey,
            title: entry.title,
            number: entry.number,
            episode: episode,
          ),
        ],
        resume: true,
        loadItems: src == null
            ? null
            : () async {
                final units = await loadUnits(
                  service: service,
                  media: media,
                  source: src,
                  season: seasonOf(episode),
                );
                if (units == null) return null;
                return [
                  for (final u in units)
                    PlayItem(
                      key: u.slot,
                      title: playTitleOf(u),
                      number: u.value,
                      episode: u.raw,
                      unit: u,
                    ),
                ];
              },
      ),
      context: context,
    );
  } else {
    await openReader(
      ReaderRequest(
        service: service,
        media: media,
        source: src,
        units: [
          WatchUnit(
            raw: episode,
            number: entry.unitKey,
            key: entry.unitKey,
            value: entry.number,
            title: entry.title,
          ),
        ],
        index: 0,
        loadUnits: src == null
            ? null
            : () => loadUnits(service: service, media: media, source: src),
      ),
      context: context,
    );
  }
  ResumeStore.endSession(service, media);
}
