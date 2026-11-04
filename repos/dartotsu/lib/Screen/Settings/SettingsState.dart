import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../Api/Discord/DiscordPresence.dart';
import '../../Utils/Function.dart';
import '../../Widgets/Components/ScreenState.dart';
import 'SettingsCategories.dart';
import 'Widgets/DonateSheet.dart';

class SettingsState extends ScreenState {
  DiscordPresence get presence => DiscordPresence.browsing('Tweaking settings');

  @override
  void onInit() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) maybeShowDonateSheet(context);
    });
    if (settingsAppVersion.value.isEmpty) unawaited(_loadVersion());
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    final hash = (await loadEnv('hash')) ?? '';
    final short = hash.length > 7 ? hash.substring(0, 7) : hash;
    settingsAppVersion.value = short.isEmpty
        ? 'v${info.version}'
        : 'v${info.version}+$short';
  }
}
