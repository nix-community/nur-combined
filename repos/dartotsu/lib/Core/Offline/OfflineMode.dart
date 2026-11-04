import 'dart:async';

import '../../Utils/Functions/SnackBar.dart';
import '../State/State.dart';
import '../ThemeManager/LanguageSwitcher.dart';
import 'NetStatus.dart';
import 'OfflineGate.dart';
import 'OfflinePrefs.dart';
import 'PendingWrites.dart';

class OfflineMode extends AppController {
  final isOffline = false.live;
  final mode = offlineModePref.value.live;

  late final NetStatus _net = find<NetStatus>();
  bool _autoOffline = false;
  Disposer? _watch;
  Disposer? _gate;

  @override
  void onInit() {
    _gate = onChange(isOffline, (offline) => OfflineGate.on = offline);
    unawaited(_start());
  }

  Future<void> _start() async {
    if (mode.value == 'always') {
      isOffline.value = true;
    } else if (mode.value == 'auto') {
      if (!await _net.check()) {
        isOffline.value = true;
        _autoOffline = true;
      }
    }
    _watch = onChange(_net.online, _netChanged);
    if (!isOffline.value) unawaited(find<PendingWrites>().replay());
  }

  void _netChanged(bool online) {
    if (!online) return;
    if (_autoOffline) {
      _autoOffline = false;
      isOffline.value = false;
    }
    if (!isOffline.value) {
      unawaited(find<PendingWrites>().replay());
    }
  }

  Future<void> setMode(String next) async {
    mode.value = next;
    offlineModePref.value = next;
    _autoOffline = false;
    final before = isOffline.value;
    switch (next) {
      case 'always':
        isOffline.value = true;
      case 'off':
        isOffline.value = false;
        unawaited(find<PendingWrites>().replay());
      default:
        final online = await _net.check();
        _autoOffline = !online;
        isOffline.value = !online;
        if (online) unawaited(find<PendingWrites>().replay());
    }
    if (isOffline.value != before) {
      snackString(
        isOffline.value ? getString.offlineEnabled : getString.offlineDisabled,
      );
    }
  }

  @override
  void onClose() {
    OfflineGate.on = false;
    _gate?.dispose();
    _watch?.dispose();
    isOffline.close();
    mode.close();
  }
}
