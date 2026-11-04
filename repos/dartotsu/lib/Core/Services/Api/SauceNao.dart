import 'dart:typed_data';

import 'package:rhttp/rhttp.dart';

import '../../NetworkManager/NetworkManager.dart';
import '../../Preferences/PrefManager.dart';
import '../../State/State.dart';

class SauceHit {
  final double similarity;
  final String title;
  final String? creator;
  final String? site;
  final String? thumbnail;
  final List<String> urls;
  final String? part;
  final bool adult;

  const SauceHit({
    required this.similarity,
    required this.title,
    this.creator,
    this.site,
    this.thumbnail,
    this.urls = const [],
    this.part,
    this.adult = false,
  });

  String? get link => urls.isEmpty ? null : urls.first;

  bool get low => similarity < 60;
}

class SauceNaoException implements Exception {
  final String message;

  const SauceNaoException(this.message);

  @override
  String toString() => message;
}

String _first(Map data, List<String> keys) {
  for (final k in keys) {
    final v = data[k];
    if (v is String && v.trim().isNotEmpty) return v.trim();
    if (v is List && v.isNotEmpty && v.first is String) {
      return v.first as String;
    }
  }
  return '';
}

SauceHit? parseSauceHit(Map result) {
  final header = result['header'] is Map ? result['header'] as Map : const {};
  final data = result['data'] is Map ? result['data'] as Map : const {};
  final similarity = double.tryParse('${header['similarity']}') ?? 0;
  final title = _first(data, [
    'title',
    'eng_name',
    'jp_name',
    'source',
    'material',
    'characters',
  ]);
  final urls = [
    for (final u in (data['ext_urls'] as List? ?? const []))
      if (u is String) u,
  ];
  if (title.isEmpty && urls.isEmpty) return null;
  final index = '${header['index_name'] ?? ''}';
  final site = index.contains(' - ')
      ? index.substring(index.indexOf(' - ') + 3).split(' - ').first
      : index;
  final part = _first(data, ['part', 'chapter']);
  final year = _first(data, ['year']);
  return SauceHit(
    similarity: similarity,
    title: title.isEmpty ? (urls.isEmpty ? '' : urls.first) : title,
    creator: _first(data, [
      'author_name',
      'member_name',
      'creator',
      'author',
      'artist',
    ]).ifEmpty,
    site: site.isEmpty ? null : site,
    thumbnail: header['thumbnail'] as String?,
    urls: urls,
    part: [part, year].where((e) => e.isNotEmpty).join(' · ').ifEmpty,
    adult: header['hidden'] == 1 || header['hidden'] == 2,
  );
}

extension on String {
  String? get ifEmpty => isEmpty ? null : this;
}

class SauceNao {
  SauceNao._();

  static const _endpoint = 'https://saucenao.com/search.php';

  static Future<List<SauceHit>> byBytes(
    Uint8List bytes, {
    String name = 'image.jpg',
  }) => _run(
    (query) => find<NetworkManager>().post(
      _endpoint,
      query: query,
      data: HttpBody.multipart({
        'file': MultipartItem.bytes(bytes: bytes, fileName: name),
      }),
    ),
  );

  static Future<List<SauceHit>> byUrl(String url) => _run(
    (query) =>
        find<NetworkManager>().get(_endpoint, query: {...query, 'url': url}),
  );

  static Future<List<SauceHit>> _run(
    Future<NetworkResponse<dynamic>> Function(Map<String, String> query) send,
  ) async {
    final key = PrefName.sauceNaoKey.value.trim();
    final res = await send({
      'output_type': '2',
      'numres': '10',
      'db': '999',
      'hide': '0',
      if (key.isNotEmpty) 'api_key': key,
    });
    final data = res.data;
    final header = data is Map && data['header'] is Map
        ? data['header'] as Map
        : const {};
    final status = (header['status'] as num?)?.toInt() ?? 0;
    if (res.statusCode == 429) {
      throw const SauceNaoException('SauceNAO is rate limited, try again soon');
    }
    if (res.statusCode == 403) {
      throw const SauceNaoException(
        'SauceNAO blocked the request. Add a free API key with the key button '
        'and try again',
      );
    }
    if (!res.isOk && status == 0) {
      throw SauceNaoException('SauceNAO failed (HTTP ${res.statusCode})');
    }
    if (status != 0) {
      throw SauceNaoException(
        '${header['message'] ?? 'SauceNAO error $status'}'.replaceAll(
          RegExp(r'<[^>]+>'),
          '',
        ),
      );
    }
    if (data is! Map) return const [];
    final hits = <SauceHit>[];
    for (final r in (data['results'] as List? ?? const [])) {
      if (r is! Map) continue;
      final hit = parseSauceHit(r);
      if (hit != null) hits.add(hit);
    }
    hits.sort((a, b) => b.similarity.compareTo(a.similarity));
    return hits;
  }
}
