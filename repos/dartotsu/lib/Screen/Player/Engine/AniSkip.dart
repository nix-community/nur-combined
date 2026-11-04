import 'dart:convert';
import 'dart:math';

import '../../../Core/NetworkManager/NetworkManager.dart';
import '../../../Core/State/State.dart';
import '../../../Logger.dart';
import '../../Detail/Watch/Data/Providers/MetaHttp.dart';
import '../../Detail/Watch/Data/WatchPrefs.dart';

enum SkipKind { opening, ending, recap, other }

class SkipDraft {
  final String key;
  final Live<String> type = 'op'.live;
  final Live<double> start;
  final Live<double> end = 0.0.live;

  SkipDraft(this.key, double startMs) : start = startMs.live;
}

double? parseClock(String input) {
  final text = input.trim();
  if (text.isEmpty) return null;
  final parts = text.split(':');
  if (parts.length > 3) return null;
  var total = 0.0;
  for (final part in parts) {
    final value = double.tryParse(part.trim());
    if (value == null || value < 0) return null;
    total = total * 60 + value;
  }
  return total;
}

const aniSkipTypes = ['op', 'ed', 'mixed-op', 'mixed-ed', 'recap'];

class SkipStamp {
  final String name;
  final SkipKind kind;
  final double start;
  final double end;

  const SkipStamp(this.name, this.kind, this.start, this.end);

  bool covers(double seconds) => seconds >= start && seconds < end;
}

SkipKind skipKindOf(String type) {
  final t = type.toLowerCase();
  if (t == 'op' || t == 'mixed-op' || t.contains('open')) {
    return SkipKind.opening;
  }
  if (t == 'ed' || t == 'mixed-ed' || t.contains('end')) return SkipKind.ending;
  if (t == 'recap') return SkipKind.recap;
  return SkipKind.other;
}

String skipName(String type) => switch (type.toLowerCase()) {
  'op' => 'Opening',
  'ed' => 'Ending',
  'recap' => 'Recap',
  'mixed-op' => 'Mixed Opening',
  'mixed-ed' => 'Mixed Ending',
  _ => type,
};

List<SkipStamp> parseAniSkip(Object? body) {
  if (body is! Map || body['found'] != true) return const [];
  final results = body['results'];
  if (results is! List) return const [];
  final out = <SkipStamp>[];
  for (final r in results) {
    if (r is! Map) continue;
    final interval = r['interval'];
    final type = r['skipType'];
    if (interval is! Map || type is! String) continue;
    final start = (interval['startTime'] as num?)?.toDouble();
    final end = (interval['endTime'] as num?)?.toDouble();
    if (start == null || end == null || end <= start) continue;
    out.add(SkipStamp(skipName(type), skipKindOf(type), start, end));
  }
  out.sort((a, b) => a.start.compareTo(b.start));
  return out;
}

class AniSkip {
  AniSkip._();

  static Future<List<SkipStamp>> fetch({
    required int malId,
    required int episode,
    required int lengthSeconds,
  }) async {
    final body = await metaGet(
      'https://api.aniskip.com/v2/skip-times/$malId/$episode'
      '?types[]=op&types[]=ed&types[]=mixed-op&types[]=mixed-ed&types[]=recap'
      '&episodeLength=$lengthSeconds',
      tag: 'ANISKIP',
    );
    return parseAniSkip(body);
  }

  static String _submitter() {
    var id = aniSkipSubmitterPref.value;
    if (id.isNotEmpty) return id;
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = [for (final b in bytes) b.toRadixString(16).padLeft(2, '0')];
    id =
        '${hex.sublist(0, 4).join()}-${hex.sublist(4, 6).join()}-'
        '${hex.sublist(6, 8).join()}-${hex.sublist(8, 10).join()}-'
        '${hex.sublist(10).join()}';
    aniSkipSubmitterPref.value = id;
    return id;
  }

  static Future<String?> submit({
    required int malId,
    required int episode,
    required String type,
    required double start,
    required double end,
    required double lengthSeconds,
  }) async {
    try {
      final res = await find<NetworkManager>()
          .post(
            'https://api.aniskip.com/v2/skip-times/$malId/$episode',
            data: {
              'skipType': type,
              'providerName': 'Dartotsu',
              'startTime': double.parse(start.toStringAsFixed(3)),
              'endTime': double.parse(end.toStringAsFixed(3)),
              'episodeLength': double.parse(lengthSeconds.toStringAsFixed(3)),
              'submitterId': _submitter(),
            },
            decodeJson: false,
          )
          .timeout(const Duration(seconds: 20));
      if (res.statusCode >= 200 && res.statusCode < 300) return null;
      final data = res.data;
      var message = 'HTTP ${res.statusCode}';
      try {
        final json = data is String ? jsonDecode(data) : data;
        if (json is Map && json['message'] is String) {
          message = json['message'] as String;
        }
      } catch (_) {}
      logger(
        'AniSkip submit -> $message',
        logLevel: LogLevel.error,
        tag: 'ANISKIP',
      );
      return message;
    } catch (e) {
      logger(
        'AniSkip submit failed: $e',
        logLevel: LogLevel.error,
        tag: 'ANISKIP',
      );
      return '$e';
    }
  }
}
