import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Detail/Watch/Data/Media/ResumeStore.dart';
import '../../Player/Components/PlayerSeekBar.dart';

String resumeLeft(ResumeEntry entry) => entry.isWatch
    ? getString.resumeAt(formatClock(entry.duration - entry.position))
    : getString.resumePage(entry.position + 1, entry.duration);

String resumeDetail(ResumeEntry entry) {
  final number = entry.number == entry.number.roundToDouble()
      ? '${entry.number.toInt()}'
      : '${entry.number}';
  final unit = entry.isWatch
      ? getString.watchEpisodeNumber(number)
      : getString.watchChapterNumber(number);
  return '$unit • ${resumeLeft(entry)}';
}
