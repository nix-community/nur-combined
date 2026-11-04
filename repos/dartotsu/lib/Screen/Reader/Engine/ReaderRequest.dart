import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';

import '../../../Core/Services/MediaService.dart';
import '../../../Core/Services/Model/Media.dart';
import '../../Detail/Watch/Data/EpisodeUnits.dart';

class ReaderRequest {
  final MediaService service;
  final Media media;
  final Source? source;
  List<WatchUnit> units;
  final int index;
  final List<PageUrl>? pages;
  final Future<List<WatchUnit>?> Function()? loadUnits;
  final bool online;
  final String? file;

  ReaderRequest({
    required this.service,
    required this.media,
    this.source,
    required this.units,
    required this.index,
    this.pages,
    this.loadUnits,
    this.online = false,
    this.file,
  });

  ReaderRequest withPages(List<PageUrl> loaded) => ReaderRequest(
    service: service,
    media: media,
    source: source,
    units: units,
    index: index,
    pages: loaded,
    loadUnits: loadUnits,
    online: online,
    file: file,
  );

  bool get novel =>
      media.format?.toLowerCase() == 'novel' ||
      (source ?? media.sourceData)?.itemType == ItemType.novel;
}
