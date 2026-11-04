import 'dart:io';

import 'package:flutter_displaymode/flutter_displaymode.dart';

import '../../Core/Preferences/PrefManager.dart';
import '../../Logger.dart';

Future<void> applyRefreshRate() async {
  if (!Platform.isAndroid) return;
  try {
    if (PrefName.highRefreshRate.value) {
      await FlutterDisplayMode.setHighRefreshRate();
    } else {
      await FlutterDisplayMode.setPreferredMode(DisplayMode.auto);
    }
  } catch (e, st) {
    logError('DisplayMode', e, st);
  }
}

Future<void> matchRefreshRate(double fps) async {
  if (!Platform.isAndroid || !PrefName.highRefreshRate.value || fps <= 0) {
    return;
  }
  try {
    final active = await FlutterDisplayMode.active;
    final modes =
        (await FlutterDisplayMode.supported)
            .where((m) => m.width == active.width && m.height == active.height)
            .where((m) => m.refreshRate >= fps - 0.5)
            .toList()
          ..sort((a, b) => a.refreshRate.compareTo(b.refreshRate));
    if (modes.isEmpty) return;
    bool whole(DisplayMode m) {
      final ratio = m.refreshRate / fps;
      return (ratio - ratio.round()).abs() < 0.03;
    }

    final pick =
        modes.where((m) => m.refreshRate <= 60.5 && whole(m)).firstOrNull ??
        modes.first;
    await FlutterDisplayMode.setPreferredMode(pick);
  } catch (e, st) {
    logError('DisplayMode', e, st);
  }
}
