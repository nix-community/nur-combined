import 'dart:io';

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../../Logger.dart';
import '../State/State.dart';

class Biometric {
  static const _channel = MethodChannel('dartotsu/biometric');
  static final _auth = LocalAuthentication();

  static final available = false.live;

  static bool get _native => Platform.isAndroid;

  static bool get _supported =>
      Platform.isAndroid ||
      Platform.isIOS ||
      Platform.isMacOS ||
      Platform.isWindows;

  static Future<void>? _probing;

  static Future<void> probe() => _probing ??= _probe();

  static Future<void> _probe() async {
    if (!_supported) return;
    try {
      available.value = _native
          ? await _channel.invokeMethod<bool>('available') ?? false
          : await _auth.isDeviceSupported() &&
                (Platform.isWindows ||
                    (await _auth.getAvailableBiometrics()).isNotEmpty);
    } catch (e) {
      logger('Biometric probe failed: $e', tag: 'LOCK');
      available.value = false;
    }
  }

  static Future<bool> authenticate({
    required String reason,
    required String cancel,
  }) async {
    if (!_supported) return false;
    try {
      if (_native) {
        return await _channel.invokeMethod<bool>('authenticate', {
              'title': reason,
              'cancel': cancel,
            }) ??
            false;
      }
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: !Platform.isWindows,
        persistAcrossBackgrounding: true,
      );
    } catch (e) {
      logger('Biometric prompt failed: $e', tag: 'LOCK');
      return false;
    }
  }
}
