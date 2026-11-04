import 'dart:io';

import 'package:flutter/services.dart';

import '../../../Logger.dart';

class VolumeKeys {
  VolumeKeys._();

  static const _channel = MethodChannel('dartotsu/volumekeys');
  static void Function(int direction)? _handler;

  static bool get supported => Platform.isAndroid;

  static Future<void> enable(void Function(int direction) onKey) async {
    if (!supported) return;
    _handler = onKey;
    _channel.setMethodCallHandler((call) async {
      if (call.method != 'key') return;
      _handler?.call(call.arguments == 'up' ? -1 : 1);
    });
    await _set(true);
  }

  static Future<void> disable() async {
    if (!supported) return;
    _handler = null;
    await _set(false);
  }

  static Future<void> _set(bool on) async {
    try {
      await _channel.invokeMethod<void>('setEnabled', on);
    } catch (e, st) {
      logError('VolumeKeys', e, st, 'setEnabled($on) failed');
    }
  }
}
