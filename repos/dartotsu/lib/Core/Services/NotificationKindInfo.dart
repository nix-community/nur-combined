import 'package:flutter/material.dart';

import '../ThemeManager/LanguageSwitcher.dart';
import 'ServiceNotification.dart';

extension NotificationKindInfo on NotificationKind? {
  String get label => switch (this) {
    null => getString.notificationsAll,
    NotificationKind.airing => getString.notificationsAiring,
    NotificationKind.media => getString.notificationsMedia,
    NotificationKind.reply => getString.notificationsReplies,
    NotificationKind.mention => getString.notificationsMentions,
    NotificationKind.message => getString.notificationsMessages,
    NotificationKind.like => getString.notificationsLikes,
    NotificationKind.follow => getString.notificationsFollows,
    NotificationKind.other => getString.notificationsAll,
  };

  IconData get icon => switch (this) {
    null => Icons.notifications_rounded,
    NotificationKind.airing => Icons.live_tv_rounded,
    NotificationKind.media => Icons.new_releases_rounded,
    NotificationKind.reply => Icons.reply_rounded,
    NotificationKind.mention => Icons.alternate_email_rounded,
    NotificationKind.message => Icons.mail_rounded,
    NotificationKind.like => Icons.favorite_rounded,
    NotificationKind.follow => Icons.person_add_alt_1_rounded,
    NotificationKind.other => Icons.notifications_rounded,
  };
}
