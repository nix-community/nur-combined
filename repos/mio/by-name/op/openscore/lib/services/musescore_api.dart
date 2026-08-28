import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/score.dart';

/// MuseScore fetch helpers ported from MIT-licensed dl-librescore
/// (https://github.com/LibreScore/dl-librescore).
class MuseScoreApi {
  MuseScoreApi({http.Client? client, this.proxyBaseUrl})
    : _client = client ?? http.Client();

  final http.Client _client;

  /// Optional HTTP forward proxy base, e.g. `https://my-proxy.example/fetch?url=`
  /// The score URL is appended (URI-encoded) when set.
  final String? proxyBaseUrl;

  static const _userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36 Edg/125.0.2535.85';

  static final _scoreUrlRe = RegExp(
    r'^(?:https?:\/\/)?(?:(?:s|www)\.)?musescore\.com\/[^\s]+$',
    caseSensitive: false,
  );

  static final _idMetaRe = RegExp(
    r'<meta property="al:ios:url" content="musescore://score/(\d+)">',
  );
  static final _titleMetaRe = RegExp(
    r'<meta property="og:title" content="([^"]*)">',
  );
  static final _thumbLinkRe = RegExp(
    r'<link[^>]*?href="([^"]+)"[^>]*?rel="preload"[^>]*?as="image"',
  );
  static final _pageCountRe = RegExp(r'pages(?:&quot;|"):(\d+)');
  static final _dimensionsRe = RegExp(
    r'dimensions(?:&quot;|"):(?:&quot;|")(\d+)x(\d+)(?:&quot;|"),',
  );
  static final _jsBundleRe = RegExp(
    r'''link.+?href=["'](https://musescore\.com/static/public/build/musescore.*?(?:_es6)?/20.+?\.js)["']''',
  );
  static final _suffixRe = RegExp(r'"([^"]+)"\)\.substr\(0,4\)');
  static final _hitUrlRe = RegExp(
    r'https?://(?:(?:s|www)\.)?musescore\.com/([^\s"<>]+/scores/\d+)',
    caseSensitive: false,
  );

  void dispose() => _client.close();

  bool isScoreUrl(String input) => _scoreUrlRe.hasMatch(input.trim());

  String normalizeScoreUrl(String input) {
    var url = input.trim();
    if (!url.startsWith('http')) {
      url = 'https://$url';
    }
    return url;
  }

  Future<ScoreInfo> fetchScore(String scoreUrl) async {
    final url = normalizeScoreUrl(scoreUrl);
    final html = await _getText(url);
    if (_looksLikeCloudflare(html)) {
      throw MuseScoreException(
        'MuseScore blocked the request (Cloudflare). '
        'Set an HTTP proxy in Settings, or try again later.',
      );
    }
    final idMatch = _idMetaRe.firstMatch(html);
    if (idMatch == null) {
      throw MuseScoreException('Score not found or page could not be parsed.');
    }
    final id = int.parse(idMatch.group(1)!);
    final title = _titleMetaRe.firstMatch(html)?.group(1) ?? 'score_$id';
    final thumbRaw = _thumbLinkRe.firstMatch(html)?.group(1) ?? '';
    final thumbnailUrl = thumbRaw.split('@').first;
    final pageCount =
        int.tryParse(_pageCountRe.firstMatch(html)?.group(1) ?? '') ?? 0;
    final dim = _dimensionsRe.firstMatch(html);
    return ScoreInfo(
      id: id,
      title: _unescapeHtml(title),
      url: url,
      thumbnailUrl: thumbnailUrl,
      pageCount: pageCount,
      imageWidth: int.tryParse(dim?.group(1) ?? '') ?? 0,
      imageHeight: int.tryParse(dim?.group(2) ?? '') ?? 0,
    );
  }

  /// Search via DuckDuckGo HTML (MuseScore search is often behind Cloudflare).
  Future<List<SearchHit>> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const [];

    if (isScoreUrl(q)) {
      final score = await fetchScore(q);
      return [
        SearchHit(id: score.id, title: score.title, url: score.url),
      ];
    }

    final uri = Uri.https('html.duckduckgo.com', '/html/', {
      'q': 'site:musescore.com/scores $q',
    });
    final html = await _getText(uri.toString());
    final seen = <int>{};
    final hits = <SearchHit>[];
    for (final m in _hitUrlRe.allMatches(html)) {
      final path = m.group(1)!;
      final id = int.tryParse(path.split('/').last);
      if (id == null || !seen.add(id)) continue;
      final url = 'https://musescore.com/$path';
      final title = _guessTitleNear(html, m.start) ?? 'Score $id';
      hits.add(SearchHit(id: id, title: title, url: url));
      if (hits.length >= 25) break;
    }
    return hits;
  }

  Future<Uint8List> download(
    ScoreInfo score,
    DownloadFormat format, {
    void Function(String status)? onProgress,
  }) async {
    switch (format) {
      case DownloadFormat.midi:
      case DownloadFormat.mp3:
        onProgress?.call('Resolving ${format.label}…');
        final fileUrl = await getFileUrl(
          score.id,
          format == DownloadFormat.midi ? 'midi' : 'mp3',
          score.url,
        );
        onProgress?.call('Downloading ${format.label}…');
        return _getBytes(fileUrl);
      case DownloadFormat.pdf:
        return exportPdf(score, onProgress: onProgress);
    }
  }

  Future<String> getFileUrl(
    int id,
    String type,
    String scoreUrl, {
    int index = 0,
  }) async {
    final apiPath = '/api/jmuse?id=$id&type=$type&index=$index';
    var auth = await _getApiAuth(id, type, index, scoreUrl);
    var response = await _get(apiPath, headers: {'Authorization': auth});

    if (response.statusCode < 200 || response.statusCode >= 300) {
      auth = md5.convert(utf8.encode('$id$type${index}9654,4e')).toString().substring(0, 4);
      response = await _get(apiPath, headers: {'Authorization': auth});
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw MuseScoreException(
        'Failed to resolve $type URL (HTTP ${response.statusCode}). '
        'MuseScore may be blocking automated downloads.',
      );
    }

    final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final info = body['info'] as Map<String, dynamic>?;
    final url = info?['url'] as String?;
    if (url == null || url.isEmpty) {
      throw MuseScoreException('MuseScore API returned no file URL for $type.');
    }
    return url;
  }

  Future<Uint8List> exportPdf(
    ScoreInfo score, {
    void Function(String status)? onProgress,
  }) async {
    if (score.pageCount <= 0 || score.thumbnailUrl.isEmpty) {
      throw MuseScoreException('Score sheet metadata is incomplete for PDF.');
    }

    final urls = <String>[];
    for (var i = 0; i < score.pageCount; i++) {
      onProgress?.call('Fetching page ${i + 1}/${score.pageCount}…');
      if (i == 0) {
        urls.add(score.thumbnailUrl);
      } else {
        urls.add(await getFileUrl(score.id, 'img', score.url, index: i));
      }
    }

    final doc = pw.Document();
    for (var i = 0; i < urls.length; i++) {
      onProgress?.call('Building PDF ${i + 1}/${urls.length}…');
      final bytes = await _getBytes(urls[i]);
      final raster = _toPng(bytes, score.imgType);
      final image = pw.MemoryImage(raster);
      final pageFormat = (score.imageWidth > 0 && score.imageHeight > 0)
          ? PdfPageFormat(
              score.imageWidth.toDouble(),
              score.imageHeight.toDouble(),
            )
          : PdfPageFormat.a4;
      doc.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: pw.EdgeInsets.zero,
          build: (_) => pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)),
        ),
      );
    }
    onProgress?.call('Writing PDF…');
    return Uint8List.fromList(await doc.save());
  }

  Future<String> _getApiAuth(
    int id,
    String type,
    int index,
    String scoreUrl,
  ) async {
    final suffix = await _getSuffix(scoreUrl);
    final code = '$id$type$index$suffix';
    return md5.convert(utf8.encode(code)).toString().substring(0, 4);
  }

  Future<String> _getSuffix(String scoreUrl) async {
    final html = await _getText(scoreUrl);
    final bundles = _jsBundleRe.allMatches(html).map((m) => m.group(1)!).toList();
    for (final url in bundles) {
      final js = await _getText(url);
      final match = _suffixRe.firstMatch(js);
      if (match != null) return match.group(1)!;
    }
    return '9654,4e';
  }

  Future<http.Response> _get(
    String urlOrPath, {
    Map<String, String>? headers,
  }) async {
    final url = urlOrPath.startsWith('http')
        ? urlOrPath
        : 'https://musescore.com$urlOrPath';
    final target = _maybeProxy(url);
    final response = await _client.get(
      Uri.parse(target),
      headers: {
        'User-Agent': _userAgent,
        'Accept-Language': 'en-US;q=0.8',
        'Accept': '*/*',
        ...?headers,
      },
    );
    return response;
  }

  Future<String> _getText(String url) async {
    final response = await _get(url);
    final text = utf8.decode(response.bodyBytes, allowMalformed: true);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (_looksLikeCloudflare(text)) {
        throw MuseScoreException(
          'Blocked by Cloudflare (HTTP ${response.statusCode}). '
          'Configure a proxy in Settings.',
        );
      }
      throw MuseScoreException('HTTP ${response.statusCode} for $url');
    }
    return text;
  }

  Future<Uint8List> _getBytes(String url) async {
    final response = await _get(url);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw MuseScoreException('Download failed (HTTP ${response.statusCode}).');
    }
    return response.bodyBytes;
  }

  String _maybeProxy(String url) {
    final base = proxyBaseUrl?.trim();
    if (base == null || base.isEmpty) return url;
    if (base.contains('{url}')) {
      return base.replaceAll('{url}', Uri.encodeComponent(url));
    }
    return '$base${Uri.encodeComponent(url)}';
  }

  static bool _looksLikeCloudflare(String html) {
    return html.contains('Just a moment...') ||
        html.contains('cf-browser-verification') ||
        html.contains('Attention Required! | Cloudflare');
  }

  static String _unescapeHtml(String s) {
    return s
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
  }

  static String? _guessTitleNear(String html, int index) {
    final start = (index - 200).clamp(0, html.length);
    final slice = html.substring(start, (index + 200).clamp(0, html.length));
    final m = RegExp(
      r'>([^<]{3,120})</a>',
      caseSensitive: false,
    ).firstMatch(slice);
    final t = m?.group(1)?.trim();
    if (t == null || t.startsWith('http')) return null;
    return _unescapeHtml(t);
  }

  static Uint8List _toPng(Uint8List bytes, String imgType) {
    if (imgType == 'png' ||
        (bytes.length > 8 &&
            bytes[0] == 0x89 &&
            bytes[1] == 0x50 &&
            bytes[2] == 0x4e &&
            bytes[3] == 0x47)) {
      return bytes;
    }
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw MuseScoreException('Could not decode sheet page image.');
    }
    return Uint8List.fromList(img.encodePng(decoded));
  }
}

class MuseScoreException implements Exception {
  MuseScoreException(this.message);
  final String message;

  @override
  String toString() => message;
}
