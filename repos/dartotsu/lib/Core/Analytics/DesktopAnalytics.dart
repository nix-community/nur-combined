import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:package_info_plus/package_info_plus.dart';

import '../../Logger.dart';
import '../Preferences/PrefManager.dart';
import 'FirebaseOptions.dart';

class DesktopAnalytics {
  static const _endpoint = 'https://www.google-analytics.com/g/collect';
  static const _beat = Duration(minutes: 5);

  String? _clientId;
  String? _version;
  String? _sessionId;
  var _hit = 0;
  Timer? _timer;
  final _client = HttpClient()..connectionTimeout = const Duration(seconds: 10);

  Future<void> start() async {
    stop();
    _version ??= (await PackageInfo.fromPlatform()).version;
    _clientId = _loadClientId();
    _sessionId = '${DateTime.now().millisecondsSinceEpoch ~/ 1000}';
    _hit = 0;
    await _send('session_start', engagement: 1, first: true);
    _timer = Timer.periodic(
      _beat,
      (_) =>
          unawaited(_send('user_engagement', engagement: _beat.inMilliseconds)),
    );
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  String _loadClientId() {
    final saved = PrefName.analyticsClientId.value;
    if (saved.isNotEmpty) return saved;
    final random = Random.secure();
    final id =
        '${random.nextInt(1 << 31)}${random.nextInt(1 << 31)}.${DateTime.now().millisecondsSinceEpoch ~/ 1000}';
    PrefName.analyticsClientId.value = id;
    return id;
  }

  Future<void> _send(
    String name, {
    required int engagement,
    bool first = false,
  }) async {
    final clientId = _clientId;
    if (clientId == null) return;
    try {
      final uri = Uri.parse(_endpoint).replace(
        queryParameters: {
          'v': '2',
          'tid': DefaultFirebaseOptions.web.measurementId!,
          'cid': clientId,
          'sid': _sessionId!,
          'sct': '1',
          'seg': '1',
          'en': name,
          '_et': '$engagement',
          '_p': '${DateTime.now().millisecondsSinceEpoch}',
          '_s': '${++_hit}',
          if (first) '_ss': '1',
          'ep.platform': Platform.operatingSystem,
          'ep.app_version': _version ?? '',
          'ul': Platform.localeName.split('.').first.replaceAll('_', '-'),
        },
      );
      final request = await _client.postUrl(uri);
      request.headers.set(
        HttpHeaders.userAgentHeader,
        'Dartotsu/${_version ?? ''} (${Platform.operatingSystem})',
      );
      final response = await request.close().timeout(
        const Duration(seconds: 15),
      );
      await response.drain<void>();
    } catch (e) {
      logger('Desktop analytics failed: $e', tag: 'ANALYTICS');
    }
  }
}
