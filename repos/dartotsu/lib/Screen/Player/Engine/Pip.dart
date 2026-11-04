import 'dart:io';

import 'package:fl_pip/fl_pip.dart';

import '../../../Logger.dart';

class PlayerPip {
  PlayerPip._();

  static void Function(bool active)? _onChanged;
  static bool _mobileAvailable = false;
  static bool _armed = false;
  static Rational _ratio = const Rational.landscape();

  static bool get isMobile => Platform.isAndroid || Platform.isIOS;

  static bool get supported => isMobile && _mobileAvailable;

  static void _statusChanged() {
    final status = FlPiP().status.value?.status;
    if (status == null) return;
    _onChanged?.call(status == PiPStatus.enabled);
  }

  static Future<void> init(void Function(bool active) onChanged) async {
    _onChanged = onChanged;
    if (!isMobile) return;
    FlPiP().status.removeListener(_statusChanged);
    FlPiP().status.addListener(_statusChanged);
    try {
      _mobileAvailable = await FlPiP().isAvailable;
    } catch (e, st) {
      logError('PlayerPip', e, st, 'availability check failed');
    }
  }

  static void detach() {
    _onChanged = null;
    if (!isMobile) return;
    FlPiP().status.removeListener(_statusChanged);
  }

  static Rational _rational(int width, int height) {
    if (width <= 0 || height <= 0) return const Rational.landscape();
    final ratio = width / height;
    if (ratio < 0.42 || ratio > 2.38) return const Rational.landscape();
    return Rational(width, height);
  }

  static FlPiPAndroidConfig _android({required bool whenBackground}) =>
      FlPiPAndroidConfig(
        aspectRatio: _ratio,
        enabledWhenBackground: whenBackground,
      );

  static FlPiPiOSConfig _ios({required bool whenBackground}) => FlPiPiOSConfig(
    enabledWhenBackground: whenBackground,
    enableControls: true,
    enablePlayback: true,
  );

  static Future<bool> enter({int width = 16, int height = 9}) async {
    try {
      if (isMobile) {
        _ratio = _rational(width, height);
        _armed = false;
        return await FlPiP().enable(
          android: _android(whenBackground: false),
          ios: _ios(whenBackground: false),
        );
      }
      return false;
    } on Object catch (e, st) {
      logError('PlayerPip', e, st, 'enter failed');
      return false;
    }
  }

  static Future<void> exit() async {
    try {
      if (isMobile) await FlPiP().disable();
    } on Object catch (e, st) {
      logError('PlayerPip', e, st, 'exit failed');
    }
  }

  static Future<void> setAuto(bool on) async {
    if (!isMobile || !_mobileAvailable) return;
    final active = FlPiP().status.value?.status == PiPStatus.enabled;
    if (active) return;
    try {
      if (on) {
        _armed = true;
        await FlPiP().enable(
          android: _android(whenBackground: true),
          ios: _ios(whenBackground: true),
        );
      } else if (_armed) {
        _armed = false;
        await FlPiP().disable();
      }
    } on Object catch (e, st) {
      logError('PlayerPip', e, st, 'setAuto failed');
    }
  }

  static Future<void> setRatio(int width, int height) async {
    final next = _rational(width, height);
    if (next.numerator == _ratio.numerator &&
        next.denominator == _ratio.denominator) {
      return;
    }
    _ratio = next;
    if (_armed) await setAuto(true);
  }
}
