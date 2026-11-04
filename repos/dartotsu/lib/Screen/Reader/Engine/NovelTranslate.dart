import 'dart:convert';

import '../../../Core/NetworkManager/NetworkManager.dart';
import '../../../Core/State/State.dart';
import '../../../Logger.dart';
import 'NovelText.dart';

const _endpoint = 'https://translate.googleapis.com/translate_a/single';
const _batchChars = 1200;
const _parallel = 3;

class NovelTranslator {
  final _cache = <String, String>{};

  String _key(String to, String text) => '$to\u0000$text';

  Future<List<NovelBlock>> translate(
    List<NovelBlock> blocks,
    String to, {
    bool Function()? cancelled,
    void Function(double progress)? onProgress,
  }) async {
    final texts = <int, String>{};
    for (var i = 0; i < blocks.length; i++) {
      final b = blocks[i];
      if (b is NovelParagraph) texts[i] = b.text;
    }
    final batches = <List<int>>[];
    var current = <int>[];
    var size = 0;
    for (final e in texts.entries) {
      if (_cache.containsKey(_key(to, e.value))) continue;
      if (current.isNotEmpty && size + e.value.length > _batchChars) {
        batches.add(current);
        current = [];
        size = 0;
      }
      current.add(e.key);
      size += e.value.length;
    }
    if (current.isNotEmpty) batches.add(current);

    var done = 0;
    Future<void> run(List<int> batch) async {
      if (cancelled?.call() ?? false) return;
      final source = [for (final i in batch) texts[i]!];
      final result = await _batch(source, to);
      for (var k = 0; k < batch.length; k++) {
        _cache[_key(to, source[k])] = result[k];
      }
      onProgress?.call(++done / batches.length);
    }

    var next = 0;
    Future<void> worker() async {
      while (next < batches.length) {
        if (cancelled?.call() ?? false) return;
        await run(batches[next++]);
      }
    }

    await Future.wait([for (var w = 0; w < _parallel; w++) worker()]);
    return [
      for (var i = 0; i < blocks.length; i++)
        if (blocks[i] case NovelParagraph p)
          NovelParagraph(_cache[_key(to, p.text)] ?? p.text, heading: p.heading)
        else
          blocks[i],
    ];
  }

  Future<List<String>> _batch(List<String> texts, String to) async {
    if (texts.length == 1) return [await _one(texts.first, to)];
    try {
      final joined = await _one(texts.join('\n'), to);
      final parts = joined.split('\n');
      if (parts.length == texts.length) return parts;
    } catch (e) {
      logger(
        'Translate batch failed: $e',
        logLevel: LogLevel.warning,
        tag: 'READER',
      );
    }
    return [for (final t in texts) await _one(t, to)];
  }

  Future<String> _one(String text, String to) async {
    Object? error;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final res = await find<NetworkManager>().get(
          _endpoint,
          query: {
            'client': 'gtx',
            'sl': 'auto',
            'tl': _code(to),
            'dt': 't',
            'q': text,
          },
          decodeJson: false,
        );
        if (res.statusCode != 200) throw StateError('HTTP ${res.statusCode}');
        final data = jsonDecode(res.body ?? '') as List;
        final out = StringBuffer();
        for (final part in data.first as List) {
          out.write((part as List).first ?? '');
        }
        return out.toString();
      } catch (e) {
        error = e;
        await Future<void>.delayed(Duration(milliseconds: 400 * (attempt + 1)));
      }
    }
    throw error ?? StateError('Translation failed');
  }
}

String _code(String lang) => switch (lang.toLowerCase()) {
  'zh-hans' => 'zh-CN',
  'zh-hant' => 'zh-TW',
  'fil' => 'tl',
  _ => lang,
};
