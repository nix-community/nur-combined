import 'dart:typed_data';

import 'package:rhttp/rhttp.dart';

import '../../NetworkManager/NetworkManager.dart';
import '../../State/State.dart';
import '../../ThemeManager/LanguageSwitcher.dart';

class TraceHit {
  final int anilistId;
  final int? malId;
  final String title;
  final String? nativeTitle;
  final bool adult;
  final String? episode;
  final double from;
  final double to;
  final double similarity;
  final String? video;
  final String? image;

  const TraceHit({
    required this.anilistId,
    this.malId,
    required this.title,
    this.nativeTitle,
    this.adult = false,
    this.episode,
    this.from = 0,
    this.to = 0,
    this.similarity = 0,
    this.video,
    this.image,
  });

  factory TraceHit.fromJson(Map<String, dynamic> j) {
    final al = j['anilist'];
    final info = al is Map ? al : const {};
    final titles = info['title'] is Map ? info['title'] as Map : const {};
    final episode = j['episode'];
    final name =
        titles['english'] ??
        titles['romaji'] ??
        titles['native'] ??
        j['filename'] ??
        '';
    return TraceHit(
      anilistId: al is Map
          ? (al['id'] as num?)?.toInt() ?? 0
          : (al as num?)?.toInt() ?? 0,
      malId: (info['idMal'] as num?)?.toInt(),
      title: '$name',
      nativeTitle: titles['native'] as String?,
      adult: info['isAdult'] == true,
      episode: switch (episode) {
        null => null,
        List l => l.isEmpty ? null : '${l.first}',
        final e => '$e',
      },
      from: (j['from'] as num?)?.toDouble() ?? 0,
      to: (j['to'] as num?)?.toDouble() ?? 0,
      similarity: (j['similarity'] as num?)?.toDouble() ?? 0,
      video: j['video'] as String?,
      image: j['image'] as String?,
    );
  }

  String get time {
    String clock(double s) {
      final total = s.round();
      final m = total ~/ 60;
      final sec = total % 60;
      return '$m:${sec.toString().padLeft(2, '0')}';
    }

    return clock(from);
  }
}

class TraceMoeException implements Exception {
  final String message;

  const TraceMoeException(this.message);

  @override
  String toString() => message;
}

class TraceMoe {
  TraceMoe._();

  static const _search = 'https://api.trace.moe/search';
  static const _query = {'anilistInfo': '1', 'cutBorders': '1'};

  static Future<List<TraceHit>> byBytes(
    Uint8List bytes, {
    String name = 'image.jpg',
  }) => _run(
    () => find<NetworkManager>().post(
      _search,
      query: _query,
      data: HttpBody.multipart({
        'image': MultipartItem.bytes(bytes: bytes, fileName: name),
      }),
    ),
  );

  static Future<List<TraceHit>> byUrl(String url) => _run(
    () => find<NetworkManager>().get(_search, query: {..._query, 'url': url}),
  );

  static Future<List<TraceHit>> _run(
    Future<NetworkResponse<dynamic>> Function() send,
  ) async {
    final res = await send();
    final data = res.data;
    final error = data is Map ? data['error'] : null;
    if (!res.isOk || (error is String && error.isNotEmpty)) {
      throw TraceMoeException(
        error is String && error.isNotEmpty
            ? error
            : switch (res.statusCode) {
                402 => getString.imageSearchQuota,
                429 => getString.imageSearchBusy,
                _ => getString.imageSearchFailed(res.statusCode),
              },
      );
    }
    if (data is! Map) return const [];
    return [
      for (final r in (data['result'] as List? ?? const []))
        if (r is Map) TraceHit.fromJson(Map<String, dynamic>.from(r)),
    ];
  }
}
