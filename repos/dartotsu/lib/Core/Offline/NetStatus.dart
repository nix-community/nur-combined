import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

import '../State/State.dart';

enum NetKind { none, wifi, ethernet, mobile, other }

class NetStatus extends AppController {
  static const _hosts = ['one.one.one.one', 'google.com'];
  static const _channel = MethodChannel('dartotsu/network');

  final online = true.live;
  final kind = NetKind.other.live;
  final metered = false.live;
  Timer? _timer;
  StreamSubscription<List<ConnectivityResult>>? _changes;

  @override
  void onInit() {
    unawaited(check());
    unawaited(_readKind());
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => check());
    _changes = Connectivity().onConnectivityChanged.listen((results) {
      _apply(results);
      unawaited(check());
    });
  }

  Future<void> _readKind() async {
    try {
      _apply(await Connectivity().checkConnectivity());
    } catch (_) {}
  }

  void _apply(List<ConnectivityResult> results) {
    kind.value = results.contains(ConnectivityResult.wifi)
        ? NetKind.wifi
        : results.contains(ConnectivityResult.ethernet)
        ? NetKind.ethernet
        : results.contains(ConnectivityResult.mobile)
        ? NetKind.mobile
        : results.isEmpty || results.contains(ConnectivityResult.none)
        ? NetKind.none
        : NetKind.other;
    unawaited(_readMetered());
  }

  Future<void> _readMetered() async {
    if (Platform.isAndroid) {
      try {
        metered.value =
            await _channel.invokeMethod<bool>('isMetered') ??
            kind.value == NetKind.mobile;
        return;
      } catch (_) {}
    }
    metered.value = kind.value == NetKind.mobile;
  }

  Future<bool> check() async {
    var ok = false;
    for (final host in _hosts) {
      try {
        final found = await InternetAddress.lookup(
          host,
        ).timeout(const Duration(seconds: 4));
        if (found.isNotEmpty) {
          ok = true;
          break;
        }
      } catch (_) {}
    }
    online.value = ok;
    return ok;
  }

  @override
  void onClose() {
    _timer?.cancel();
    unawaited(_changes?.cancel());
    online.close();
  }
}
