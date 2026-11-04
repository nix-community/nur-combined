import 'package:flutter/material.dart';

import '../../../../Core/Preferences/PrefManager.dart';
import '../../../../Core/Services/Screens/NotificationAlertSettings.dart';
import '../../../../Core/Services/MediaService.dart';
import '../../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../../Model/Setting.dart';
import '../Auth.dart';

class AnilistNotificationView implements NotificationScreenView {
  @override
  List<NotificationKind> get kinds => const [
    NotificationKind.airing,
    NotificationKind.media,
    NotificationKind.reply,
    NotificationKind.mention,
    NotificationKind.message,
    NotificationKind.like,
    NotificationKind.follow,
  ];

  @override
  List<Setting> settings(BuildContext context) =>
      notificationAlertSettings(this, serviceName: getString.anilist);

  @override
  Pref<bool> get alertsPref => PrefName.activityAlerts;

  @override
  Pref<int> get pollPref => PrefName.activityPollMinutes;

  @override
  Pref<String> get mutedPref => PrefName.activityMutedKinds;

  @override
  Future<List<ServiceNotification>> unread() =>
      anilistAuth.queries.activityAlerts();

  @override
  Future<List<ServiceNotification>> notifications({int page = 1}) =>
      anilistAuth.queries.getNotifications(page: page);
}
