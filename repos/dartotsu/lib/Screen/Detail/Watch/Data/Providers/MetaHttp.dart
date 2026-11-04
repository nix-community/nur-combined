import 'dart:convert';

import '../../../../../Core/NetworkManager/NetworkManager.dart';
import '../../../../../Core/State/State.dart';
import '../../../../../Logger.dart';

Future<dynamic> metaGet(
  String url, {
  Map<String, String>? query,
  Map<String, String>? headers,
  String tag = 'META',
}) async {
  try {
    final res = await find<NetworkManager>()
        .get(url, query: query, headers: headers, decodeJson: false)
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      logger('$url -> HTTP ${res.statusCode}', tag: tag);
      return null;
    }
    final data = res.data;
    return data is String ? jsonDecode(data) : data;
  } catch (e) {
    logger('$url failed: $e', logLevel: LogLevel.error, tag: tag);
    return null;
  }
}

Future<dynamic> metaPost(
  String url,
  Object body, {
  Map<String, String>? headers,
  String tag = 'META',
}) async {
  try {
    final res = await find<NetworkManager>()
        .post(url, data: body, headers: headers, decodeJson: false)
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      logger('$url -> HTTP ${res.statusCode}', tag: tag);
      return null;
    }
    final data = res.data;
    return data is String ? jsonDecode(data) : data;
  } catch (e) {
    logger('$url failed: $e', logLevel: LogLevel.error, tag: tag);
    return null;
  }
}

String? nonBlank(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}
