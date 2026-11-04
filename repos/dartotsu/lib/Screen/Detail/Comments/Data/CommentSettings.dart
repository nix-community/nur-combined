import 'package:flutter/material.dart';

import '../../../../Model/Setting.dart';
import '../../../../Core/Preferences/PrefManager.dart';
import '../../../../Core/ThemeManager/LanguageSwitcher.dart';

List<Setting> commentNotificationSettings() => [
  Setting.switchType(
    name: getString.commentsSettingAlerts,
    description: getString.commentsSettingAlertsDesc,
    icon: Icons.notifications_active_outlined,
    isChecked: PrefName.commentsAlerts.rx.value,
    onSwitchChange: (v) => PrefName.commentsAlerts.rx.value = v,
  ),
  Setting.slider(
    name: getString.notificationsPollTitle,
    description: getString.notificationsPollDesc(
      PrefName.commentsPollMinutes.rx.value,
    ),
    icon: Icons.schedule_rounded,
    isVisible: PrefName.commentsAlerts.rx.value,
    minValue: 1,
    maxValue: 60,
    initialValue: PrefName.commentsPollMinutes.rx.value,
    onSliderChange: (v) => PrefName.commentsPollMinutes.rx.value = v,
  ),
];
