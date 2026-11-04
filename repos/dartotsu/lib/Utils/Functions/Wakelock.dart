import 'package:wakelock_plus/wakelock_plus.dart';

import '../../Logger.dart';

Future<void> setWakelock(bool on) async {
  try {
    await WakelockPlus.toggle(enable: on);
  } catch (e) {
    logWarn(
      'Wakelock ${on ? 'enable' : 'disable'} failed: $e',
      tag: 'WAKELOCK',
    );
  }
}
