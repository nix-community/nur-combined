import '../../../Core/Services/MediaService.dart';
import '../../../Core/Services/Model/Media.dart';
import '../../../Utils/Function.dart';

String airedRange(Media m) {
  final start = m.startDate?.getFormattedDate();
  final end = m.endDate?.getFormattedDate();
  if (start == null) return '';
  if (end == null || end == start) return start;
  return '$start  –  $end';
}

List<ScreenWidget> nameSections(
  Media m, {
  String originalLabel = 'Romaji',
  String translatedLabel = 'English',
  int minRows = 1,
}) {
  final rows = [
    if (m.nameRomaji?.isNotEmpty ?? false) (originalLabel, m.nameRomaji!),
    if ((m.name?.isNotEmpty ?? false) && m.name != m.nameRomaji)
      (translatedLabel, m.name!),
  ];
  return [
    if (rows.length >= minRows)
      ScreenWidget.data('Names', ScreenData(rows: rows, columns: 1)),
    if (m.synonyms.isNotEmpty)
      ScreenWidget.data('Synonyms', ScreenData(chips: m.synonyms)),
  ];
}

List<ScreenWidget> linkChips(String title, List<(String, String)>? links) {
  if (links == null || links.isEmpty) return const [];
  final byName = {for (final (name, url) in links) name: url};
  return [
    ScreenWidget.data(
      title,
      ScreenData(
        chips: byName.keys.toList(),
        onChipTap: (name) => openLinkInBrowser(byName[name]!),
      ),
    ),
  ];
}
