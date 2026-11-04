import 'package:flutter/material.dart';

import '../../../Core/Downloads/DownloadPrefs.dart';
import '../../../Core/Offline/OfflineMode.dart';
import '../../../Core/Offline/PendingWrites.dart';
import '../../../Core/State/State.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Model/Setting.dart';
import '../../../Utils/Functions/NavigateToScreen.dart';
import '../../../Widgets/Components/AppControls.dart';
import '../../Downloads/DownloadsScreen.dart';
import '../Widgets/SegmentedSetting.dart';

List<Setting> downloadSettings(BuildContext context) {
  final offline = find<OfflineMode>();
  final pending = find<PendingWrites>();
  return [
    Setting.normal(
      name: getString.downloadsTitle,
      description: getString.downloadsOpenDesc,
      icon: Icons.download_rounded,
      isActivity: true,
      onClick: () => navigateToPage(context, const DownloadsScreen()),
    ),
    Setting.header(getString.downloadQueueHeader),
    segmentedSetting<int>(
      name: getString.downloadParallel,
      description: getString.downloadParallelDesc,
      icon: Icons.account_tree_rounded,
      label: getString.downloadParallel,
      value: downloadParallelPref.rx.value,
      onChanged: (v) => downloadParallelPref.rx.value = v,
      segments: [
        AppSegment(1, label: getString.downloadOneByOne),
        const AppSegment(2, label: '2'),
        const AppSegment(3, label: '3'),
        const AppSegment(4, label: '4'),
      ],
    ),
    segmentedSetting<int>(
      name: getString.downloadConnections,
      description: getString.downloadConnectionsDesc,
      icon: Icons.speed_rounded,
      label: getString.downloadConnections,
      value: downloadConnectionsPref.rx.value,
      onChanged: (v) => downloadConnectionsPref.rx.value = v,
      segments: const [
        AppSegment(1, label: '1'),
        AppSegment(2, label: '2'),
        AppSegment(4, label: '4'),
        AppSegment(8, label: '8'),
      ],
    ),
    segmentedSetting<int>(
      name: getString.downloadSpeedLimit,
      description: getString.downloadSpeedLimitDesc,
      icon: Icons.speed_rounded,
      label: getString.downloadSpeedLimit,
      value: downloadSpeedLimitPref.rx.value,
      onChanged: (v) => downloadSpeedLimitPref.rx.value = v,
      segments: [
        AppSegment(0, label: getString.downloadUnlimited),
        const AppSegment(512, label: '512 KB/s'),
        const AppSegment(1024, label: '1 MB/s'),
        const AppSegment(2048, label: '2 MB/s'),
        const AppSegment(5120, label: '5 MB/s'),
      ],
    ),
    Setting.switchType(
      name: getString.downloadWifiOnly,
      description: getString.downloadWifiOnlyDesc,
      icon: Icons.wifi_rounded,
      isChecked: downloadWifiOnlyPref.rx.value,
      onSwitchChange: (v) => downloadWifiOnlyPref.rx.value = v,
    ),
    Setting.switchType(
      name: getString.downloadMetered,
      description: getString.downloadMeteredDesc,
      icon: Icons.data_saver_on_rounded,
      isChecked: downloadMeteredPref.rx.value,
      onSwitchChange: (v) => downloadMeteredPref.rx.value = v,
    ),
    segmentedSetting<String>(
      name: getString.downloadNotifications,
      description: getString.downloadNotificationsDesc,
      icon: Icons.notifications_active_outlined,
      label: getString.downloadNotifications,
      value: downloadNotifyPref.rx.value,
      onChanged: (v) => downloadNotifyPref.rx.value = v,
      segments: [
        AppSegment('live', label: getString.downloadNotifyLive),
        AppSegment('done', label: getString.downloadNotifyDone),
        AppSegment('off', label: getString.downloadNotifyOff),
      ],
    ),
    Setting.switchType(
      name: getString.downloadInfoFile,
      description: getString.downloadInfoFileDesc,
      icon: Icons.description_outlined,
      isChecked: downloadInfoFilePref.rx.value,
      onSwitchChange: (v) => downloadInfoFilePref.rx.value = v,
    ),
    Setting.switchType(
      name: getString.downloadAutoDelete,
      description: getString.downloadAutoDeleteDesc,
      icon: Icons.auto_delete_outlined,
      isChecked: downloadAutoDeletePref.rx.value,
      onSwitchChange: (v) => downloadAutoDeletePref.rx.value = v,
    ),
    Setting.header(getString.offlineHeader),
    segmentedSetting<String>(
      name: getString.offlineMode,
      description: getString.offlineModeDesc,
      icon: Icons.cloud_off_rounded,
      label: getString.offlineMode,
      value: offline.mode.value,
      onChanged: offline.setMode,
      segments: [
        AppSegment('auto', label: getString.themeModeAuto),
        AppSegment('off', label: getString.offlineModeOff),
        AppSegment('always', label: getString.offlineModeAlways),
      ],
    ),
    Setting.normal(
      name: getString.offlinePendingTitle,
      description: pending.entries.isEmpty
          ? getString.offlinePendingNone
          : getString.offlinePending(pending.entries.length),
      icon: Icons.sync_rounded,
      onClick: pending.entries.isEmpty ? null : pending.replay,
    ),
  ];
}
