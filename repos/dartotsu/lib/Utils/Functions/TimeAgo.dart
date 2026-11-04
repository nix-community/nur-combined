import 'package:intl/intl.dart';

import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Core/ThemeManager/LocaleController.dart';
import '../../Core/State/State.dart';

String timeAgo(int epochSeconds) {
  if (epochSeconds <= 0) return '';
  final date = DateTime.fromMillisecondsSinceEpoch(epochSeconds * 1000);
  if (date.year < 2001) return '';
  final diff = DateTime.now().difference(date);
  if (diff.inDays >= 7) {
    final locale = find<LocaleController>().locale.toString();
    return DateFormat.yMMMd(locale).format(date);
  }
  if (diff.inDays >= 1) return getString.daysAgo(diff.inDays);
  if (diff.inHours >= 1) return getString.hoursAgo(diff.inHours);
  if (diff.inMinutes >= 1) return getString.minutesAgo(diff.inMinutes);
  return getString.justNow;
}
