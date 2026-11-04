import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../Logger.dart';

class DownloadService {
  DownloadService._();

  static const _channel = MethodChannel('dartotsu/downloads');
  static bool _running = false;

  static bool get supported => Platform.isAndroid;

  static Future<bool> sync({
    required bool active,
    required String title,
    required String text,
    int percent = -1,
    String? sub,
  }) async {
    if (!supported) return false;
    try {
      if (!active) {
        if (_running) {
          _running = false;
          await _channel.invokeMethod('stop');
        }
        return true;
      }
      if (!_running) {
        final lifecycle = WidgetsBinding.instance.lifecycleState;
        if (lifecycle != null && lifecycle != AppLifecycleState.resumed) {
          return false;
        }
      }
      final ok = await _channel.invokeMethod<bool>('start', {
        'title': title,
        'text': text,
        'percent': percent,
        'sub': sub,
      });
      _running = ok == true;
      return _running;
    } catch (e) {
      logger('Download service failed: $e', tag: 'DOWNLOAD');
      return false;
    }
  }
}
