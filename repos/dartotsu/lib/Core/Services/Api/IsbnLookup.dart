import 'dart:convert';

import '../../NetworkManager/NetworkManager.dart';
import '../../State/State.dart';

String? normalizeIsbn(String raw) {
  final digits = raw.replaceAll(RegExp(r'[^0-9Xx]'), '').toUpperCase();
  if (digits.length == 13 && RegExp(r'^\d{13}$').hasMatch(digits)) {
    return digits;
  }
  if (digits.length == 10 && RegExp(r'^\d{9}[\dX]$').hasMatch(digits)) {
    return digits;
  }
  return null;
}

final _tail = RegExp(
  r'(\s*[,:\-–—]?\s*)(\(?\b(vol(ume)?|v|book|part|no|#)\b\.?\s*\d+\)?.*|\(?\d+\)?)$',
  caseSensitive: false,
);
final _brackets = RegExp(r'\s*[\(\[][^\)\]]*[\)\]]');
final _edition = RegExp(
  r'\b(light novel|manga|novel|omnibus|2-in-1|3-in-1|collector.?s edition|deluxe edition)\b',
  caseSensitive: false,
);

String cleanBookTitle(String title) {
  var out = title.split(RegExp(r'\s*:\s+')).first;
  out = out.replaceAll(_brackets, '');
  out = out.replaceAll(_edition, '');
  out = out.replaceAll(RegExp(r'\s{2,}'), ' ').trim();
  for (var i = 0; i < 2; i++) {
    final next = out.replaceFirst(_tail, '').trim();
    if (next.isEmpty) break;
    out = next;
  }
  out = out.replaceAll(RegExp(r'[,\-–—:\s]+$'), '').trim();
  return out.isEmpty ? title.trim() : out;
}

class IsbnLookup {
  static Future<String?> title(String isbn) async {
    final code = normalizeIsbn(isbn);
    if (code == null) return null;
    final raw = await _google(code) ?? await _openLibrary(code);
    return raw == null ? null : cleanBookTitle(raw);
  }

  static Future<String?> _google(String isbn) async {
    try {
      final res = await find<NetworkManager>().get(
        'https://www.googleapis.com/books/v1/volumes',
        query: {'q': 'isbn:$isbn', 'maxResults': '1'},
        decodeJson: false,
      );
      if (res.statusCode != 200) return null;
      final items = (jsonDecode(res.body ?? '{}') as Map)['items'];
      if (items is! List || items.isEmpty) return null;
      final info = (items.first as Map)['volumeInfo'];
      final title = info is Map ? info['title'] : null;
      return title is String && title.trim().isNotEmpty ? title : null;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> _openLibrary(String isbn) async {
    try {
      final res = await find<NetworkManager>().get(
        'https://openlibrary.org/api/books',
        query: {'bibkeys': 'ISBN:$isbn', 'format': 'json', 'jscmd': 'data'},
        decodeJson: false,
      );
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body ?? '{}') as Map;
      final book = data['ISBN:$isbn'];
      final title = book is Map ? book['title'] : null;
      return title is String && title.trim().isNotEmpty ? title : null;
    } catch (_) {
      return null;
    }
  }
}
