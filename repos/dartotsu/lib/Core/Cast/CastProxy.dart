import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'CastHttp.dart';

const _agent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)';

class CastSubtitle {
  final String source;
  final String label;

  const CastSubtitle(this.source, this.label);
}

class CastProxy {
  HttpServer? _server;
  String? _video;
  List<CastSubtitle> _subtitles = const [];
  Map<String, String> _headers = const {};
  String _host = '127.0.0.1';
  final _client = HttpClient()..autoUncompress = false;

  String? videoUrl;
  List<String> subtitleUrls = const [];
  bool isHls = false;
  String contentType = 'video/mp4';

  bool get running => _server != null;

  Future<void> start({
    required String video,
    Map<String, String>? headers,
    List<CastSubtitle> subtitles = const [],
    ({String host, int port})? towards,
  }) async {
    await stop();
    _video = video;
    _subtitles = [
      for (final s in subtitles)
        if (s.source.isNotEmpty) s,
    ];
    _headers = {...?headers};
    final server = _server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
    _host = await _localIp(towards);
    final base = 'http://$_host:${server.port}';
    final sniffed = await _sniff(video);
    isHls = sniffed.hls;
    contentType = isHls ? 'application/x-mpegURL' : sniffed.type;
    videoUrl = isHls ? '$base/hls/master.m3u8' : '$base/video';
    subtitleUrls = [
      for (var i = 0; i < _subtitles.length; i++) '$base/subtitles/$i.vtt',
    ];
    server.listen(_handle);
  }

  Future<void> stop() async {
    final server = _server;
    _server = null;
    videoUrl = null;
    subtitleUrls = const [];
    isHls = false;
    contentType = 'video/mp4';
    _video = null;
    _subtitles = const [];
    try {
      await server?.close(force: true);
    } catch (_) {}
  }

  void dispose() {
    unawaited(stop());
    _client.close(force: true);
  }

  String get _base => 'http://$_host:${_server?.port}';

  static String _typeByName(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
    if (path.endsWith('.webm')) return 'video/webm';
    if (path.endsWith('.mkv')) return 'video/x-matroska';
    if (path.endsWith('.mp3')) return 'audio/mpeg';
    if (path.endsWith('.m4a') || path.endsWith('.aac')) return 'audio/mp4';
    return 'video/mp4';
  }

  static bool _isMediaType(String? type) {
    final lower = (type ?? '').toLowerCase();
    return lower.startsWith('video/') ||
        lower.startsWith('audio/') ||
        lower.contains('mpegurl') ||
        lower.startsWith('text/vtt') ||
        lower == 'application/mp4';
  }

  static String _segmentType(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? '';
    if (path.endsWith('.m4s') ||
        path.endsWith('.mp4') ||
        path.endsWith('.cmfv') ||
        path.endsWith('.cmfa')) {
      return 'video/mp4';
    }
    if (path.endsWith('.aac')) return 'audio/aac';
    if (path.endsWith('.vtt') || path.endsWith('.webvtt')) return 'text/vtt';
    return 'video/mp2t';
  }

  Future<({bool hls, String type})> _sniff(String url) async {
    if (_isLocal(url)) return (hls: false, type: _typeByName(url));
    if (url.toLowerCase().contains('.m3u8')) {
      return (hls: true, type: 'application/x-mpegURL');
    }
    try {
      final request = await _client
          .getUrl(Uri.parse(url))
          .timeout(const Duration(seconds: 15));
      _upstream.forEach(request.headers.set);
      request.headers.set('range', 'bytes=0-255');
      final reply = await request.close().timeout(const Duration(seconds: 15));
      if (reply.statusCode >= 400) {
        await reply.drain<void>();
        return (hls: false, type: _typeByName(url));
      }
      final type = reply.headers.value('content-type');
      final head = <int>[];
      await for (final chunk in reply.timeout(const Duration(seconds: 15))) {
        head.addAll(chunk);
        if (head.length >= 256) break;
      }
      final text = utf8.decode(head, allowMalformed: true).trimLeft();
      final bom = text.startsWith('\uFEFF') ? text.substring(1) : text;
      if ((type ?? '').toLowerCase().contains('mpegurl') ||
          bom.startsWith('#EXTM3U')) {
        return (hls: true, type: 'application/x-mpegURL');
      }
      final plain = type?.split(';').first.trim().toLowerCase();
      if (plain != null &&
          (plain.startsWith('video/') || plain.startsWith('audio/')) &&
          plain != 'video/mp2t') {
        return (hls: false, type: plain);
      }
    } catch (_) {}
    return (hls: false, type: _typeByName(url));
  }

  static bool _isLocal(String url) =>
      url.startsWith('/') || url.startsWith('file://');

  static const _virtual = [
    'veth',
    'docker',
    'br-',
    'virbr',
    'vmnet',
    'vboxnet',
    'tun',
    'tap',
    'wg',
    'tailscale',
    'zt',
    'utun',
    'awdl',
    'llw',
    'lo',
  ];

  static String pickLocalIp(Iterable<({String name, String address})> found) {
    const likely = ['wlan', 'wlo', 'wlp', 'eth', 'ap', 'rndis', 'en', 'wl'];
    final real = [
      for (final f in found)
        if (!_virtual.any(f.name.toLowerCase().startsWith)) f,
    ];
    for (final pool in [real, found.toList()]) {
      for (final pass in [true, false]) {
        for (final f in pool) {
          if (pass && !likely.any(f.name.toLowerCase().contains)) continue;
          return f.address;
        }
      }
    }
    return '127.0.0.1';
  }

  static Future<String> _localIp(({String host, int port})? towards) async {
    if (towards != null) {
      final reached = await localAddressToward(towards.host, towards.port);
      if (reached != null && reached != '127.0.0.1') return reached;
    }
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
    );
    return pickLocalIp([
      for (final iface in interfaces)
        for (final addr in iface.addresses)
          if (!addr.isLoopback) (name: iface.name, address: addr.address),
    ]);
  }

  Future<void> _handle(HttpRequest request) async {
    final response = request.response;
    response.headers
      ..set('Access-Control-Allow-Origin', '*')
      ..set('Access-Control-Allow-Methods', 'GET, HEAD, OPTIONS')
      ..set('Access-Control-Allow-Headers', '*')
      ..set('Access-Control-Expose-Headers', '*');
    try {
      if (request.method == 'OPTIONS') {
        response.statusCode = HttpStatus.ok;
        await response.close();
        return;
      }
      switch (request.uri.path) {
        case '/video':
          await _serveVideo(request);
        case '/hls/master.m3u8':
          await _serveMaster(request);
        case '/hls/variant.m3u8':
          await _serveVariant(request);
        case '/hls/segment':
          await _serveSegment(request);
        case '/hls/subtitles.m3u8':
          await _serveSubtitlePlaylist(request);
        case final path when path.startsWith('/subtitles/'):
          await _serveSubtitle(
            request,
            int.tryParse(path.substring(11).replaceAll('.vtt', '')) ?? -1,
          );
        default:
          response.statusCode = HttpStatus.notFound;
          await response.close();
      }
    } catch (_) {
      try {
        response.statusCode = HttpStatus.internalServerError;
        await response.close();
      } catch (_) {}
    }
  }

  Map<String, String> get _upstream {
    final out = {..._headers};
    if (!out.keys.any((k) => k.toLowerCase() == 'user-agent')) {
      out['User-Agent'] = _agent;
    }
    return out;
  }

  Map<String, String> _outgoing(HttpRequest request) {
    final out = _upstream;
    final range = request.headers.value('range');
    if (range != null) out['range'] = range;
    return out;
  }

  Future<void> _pipe(
    HttpRequest request,
    String url, {
    String method = 'GET',
    String? mediaType,
  }) async {
    final upstream = await _client.openUrl(method, Uri.parse(url));
    _outgoing(request).forEach(upstream.headers.set);
    final reply = await upstream.close();
    final response = request.response..statusCode = reply.statusCode;
    reply.headers.forEach((name, values) {
      final lower = name.toLowerCase();
      if (lower == 'transfer-encoding' ||
          lower.startsWith('access-control-') ||
          lower == 'connection') {
        return;
      }
      for (final value in values) {
        response.headers.set(name, value);
      }
    });
    if (mediaType != null &&
        !_isMediaType(response.headers.value('content-type'))) {
      response.headers.set('content-type', mediaType);
    }
    await reply.pipe(response);
  }

  Future<String?> _text(String url) async {
    final upstream = await _client.getUrl(Uri.parse(url));
    _upstream.forEach(upstream.headers.set);
    final reply = await upstream.close();
    if (reply.statusCode != 200) {
      await reply.drain<void>();
      return null;
    }
    return reply.transform(utf8.decoder).join();
  }

  Future<void> _serveVideo(HttpRequest request) async {
    final video = _video;
    if (video == null) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }
    if (_isLocal(video)) {
      await _serveFile(request, video);
    } else {
      await _pipe(
        request,
        video,
        method: request.method == 'HEAD' ? 'HEAD' : 'GET',
        mediaType: contentType,
      );
    }
  }

  Future<void> _serveFile(HttpRequest request, String path) async {
    final file = File(
      path.startsWith('file://') ? Uri.parse(path).toFilePath() : path,
    );
    final response = request.response;
    if (!await file.exists()) {
      response.statusCode = HttpStatus.notFound;
      await response.close();
      return;
    }
    final total = await file.length();
    response.headers
      ..set('Accept-Ranges', 'bytes')
      ..set('content-type', contentType);
    final range = request.headers.value('range');
    if (range != null && range.startsWith('bytes=')) {
      final parts = range.substring(6).split('-');
      final start = int.tryParse(parts[0]) ?? 0;
      final end = parts.length > 1 && parts[1].isNotEmpty
          ? int.tryParse(parts[1]) ?? total - 1
          : total - 1;
      if (start >= total || end >= total || start > end) {
        response.statusCode = HttpStatus.requestedRangeNotSatisfiable;
        response.headers.set('Content-Range', 'bytes */$total');
        await response.close();
        return;
      }
      response
        ..statusCode = HttpStatus.partialContent
        ..headers.contentLength = end - start + 1
        ..headers.set('Content-Range', 'bytes $start-$end/$total');
      await file.openRead(start, end + 1).pipe(response);
      return;
    }
    response
      ..statusCode = HttpStatus.ok
      ..headers.contentLength = total;
    await file.openRead().pipe(response);
  }

  Future<void> _serveManifest(HttpRequest request, String body) async {
    final response = request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType(
        'application',
        'vnd.apple.mpegurl',
        charset: 'utf-8',
      );
    response.write(body);
    await response.close();
  }

  Future<void> _serveMaster(HttpRequest request) async {
    final video = _video;
    final body = video == null ? null : await _text(video);
    if (body == null) {
      request.response.statusCode = HttpStatus.badGateway;
      await request.response.close();
      return;
    }
    final base = Uri.parse(video!);
    await _serveManifest(
      request,
      body.contains('#EXT-X-STREAM-INF')
          ? _rewriteMaster(body, base)
          : _rewriteMedia(body, base),
    );
  }

  String _rewriteMaster(String manifest, Uri base) {
    final withSubs = subtitleUrls.isNotEmpty;
    final out = <String>[];
    final lines = manifest.split('\n').map((l) => l.trim()).toList();
    String variant(String line) =>
        '$_base/hls/variant.m3u8?url=${Uri.encodeComponent(base.resolve(line).toString())}';
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.isEmpty) continue;
      if (line.startsWith('#EXTM3U')) {
        out.add(line);
        if (withSubs) {
          out.add(
            '#EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID="subs",NAME="${_subtitles.first.label}",DEFAULT=YES,AUTOSELECT=YES,FORCED=NO,LANGUAGE="en",URI="$_base/hls/subtitles.m3u8"',
          );
        }
      } else if (line.startsWith('#EXT-X-STREAM-INF')) {
        out.add(
          withSubs && !line.contains('SUBTITLES=')
              ? '$line,SUBTITLES="subs"'
              : line,
        );
        if (i + 1 < lines.length &&
            lines[i + 1].isNotEmpty &&
            !lines[i + 1].startsWith('#')) {
          out.add(variant(lines[++i]));
        }
      } else if (line.startsWith('#EXT-X-I-FRAME-STREAM-INF')) {
        continue;
      } else if (line.startsWith('#EXT-X-MEDIA:')) {
        final uri = RegExp(r'URI="([^"]+)"').firstMatch(line)?.group(1);
        out.add(
          uri == null
              ? line
              : line.replaceFirst('URI="$uri"', 'URI="${variant(uri)}"'),
        );
      } else if (!line.startsWith('#')) {
        out.add(variant(line));
      } else {
        out.add(line);
      }
    }
    return out.join('\n');
  }

  Future<void> _serveVariant(HttpRequest request) async {
    final target = request.uri.queryParameters['url'];
    final body = target == null ? null : await _text(target);
    if (body == null) {
      request.response.statusCode = target == null
          ? HttpStatus.badRequest
          : HttpStatus.badGateway;
      await request.response.close();
      return;
    }
    await _serveManifest(request, _rewriteMedia(body, Uri.parse(target!)));
  }

  String _rewriteMedia(String body, Uri base) {
    String segment(String url) =>
        '$_base/hls/segment?url=${Uri.encodeComponent(base.resolve(url).toString())}';
    final out = <String>[];
    for (final raw in body.split('\n')) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      if (line.startsWith('#EXT-X-KEY:') || line.startsWith('#EXT-X-MAP:')) {
        final uri = RegExp(r'URI="([^"]+)"').firstMatch(line)?.group(1);
        out.add(
          uri == null
              ? line
              : line.replaceFirst('URI="$uri"', 'URI="${segment(uri)}"'),
        );
      } else if (!line.startsWith('#')) {
        out.add(segment(line));
      } else {
        out.add(line);
      }
    }
    return out.join('\n');
  }

  Future<void> _serveSegment(HttpRequest request) async {
    final target = request.uri.queryParameters['url'];
    if (target == null) {
      request.response.statusCode = HttpStatus.badRequest;
      await request.response.close();
      return;
    }
    await _pipe(request, target, mediaType: _segmentType(target));
  }

  Future<void> _serveSubtitlePlaylist(HttpRequest request) => _serveManifest(
    request,
    '#EXTM3U\n#EXT-X-TARGETDURATION:7200\n#EXT-X-VERSION:3\n#EXT-X-MEDIA-SEQUENCE:0\n#EXTINF:7200.0,\n$_base/subtitles/0.vtt\n#EXT-X-ENDLIST\n',
  );

  Future<void> _serveSubtitle(HttpRequest request, int index) async {
    final source = index >= 0 && index < _subtitles.length
        ? _subtitles[index].source
        : null;
    String? content;
    if (source != null && source.isNotEmpty) {
      if (_isLocal(source)) {
        final file = File(
          source.startsWith('file://')
              ? Uri.parse(source).toFilePath()
              : source,
        );
        if (await file.exists()) content = await file.readAsString();
      } else {
        content = await _text(source);
      }
    }
    if (content == null || content.isEmpty) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }
    final response = request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType('text', 'vtt', charset: 'utf-8');
    response.write(_toVtt(content));
    await response.close();
  }

  static String _toVtt(String raw) {
    final text = raw.trim();
    if (text.startsWith('WEBVTT')) return text;
    final time = RegExp(r'(\d{2}:\d{2}:\d{2}),(\d{3})');
    final body = text
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAllMapped(time, (m) => '${m[1]}.${m[2]}');
    return 'WEBVTT\n\n$body';
  }
}
