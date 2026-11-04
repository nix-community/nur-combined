import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../Core/NetworkManager/NetworkManager.dart';
import '../../../Core/State/State.dart';

const kitsuApi = 'https://kitsu.io/api/edge';
const kitsuGraphqlUrl = 'https://kitsu.io/api/graphql';
const kitsuTokenUrl = 'https://kitsu.io/api/oauth/token';

class KitsuException implements Exception {
  final String message;
  final int? status;
  KitsuException(this.message, [this.status]);

  @override
  String toString() => message;
}

Map<String, dynamic> _errorBody(Object? data) {
  final body = data is String && data.isNotEmpty ? jsonDecode(data) : data;
  return body is Map<String, dynamic> ? body : <String, dynamic>{};
}

String _errorMessage(Map<String, dynamic> body, int status) {
  final errors = body['errors'];
  if (errors is List && errors.isNotEmpty && errors.first is Map) {
    final first = errors.first as Map;
    return '${first['detail'] ?? first['title'] ?? 'HTTP $status'}';
  }
  return '${body['error_description'] ?? body['error'] ?? 'HTTP $status'}';
}

Map<String, dynamic> _decode(NetworkResponse<dynamic> res) {
  final body = _errorBody(res.data);
  if (res.statusCode >= 400) {
    throw KitsuException(_errorMessage(body, res.statusCode), res.statusCode);
  }
  return body;
}

class KitsuClient {
  static const _json = 'application/vnd.api+json';

  final String Function() _token;
  final Future<bool> Function() _refresh;

  KitsuClient(this._token, this._refresh);

  NetworkManager get _net => find();

  bool get hasToken => _token().isNotEmpty;

  Map<String, String> _headers() => {
    'Accept': _json,
    'Content-Type': _json,
    if (hasToken) 'Authorization': 'Bearer ${_token()}',
  };

  Future<NetworkResponse<dynamic>> _run(
    Future<NetworkResponse<dynamic>> Function(Map<String, String> headers) call,
  ) async {
    var res = await call(_headers());
    final retriable = res.statusCode == 429 || res.statusCode >= 502;
    if (retriable) {
      await Future<void>.delayed(const Duration(seconds: 2));
      res = await call(_headers());
    }
    if (res.statusCode == 401 && hasToken && await _refresh()) {
      res = await call(_headers());
    }
    return res;
  }

  String _url(String path) => path.startsWith('http') ? path : '$kitsuApi$path';

  Future<Map<String, dynamic>> get(String path, {Map<String, String>? query}) =>
      _run((h) => _net.get(_url(path), query: query, headers: h)).then(_decode);

  Future<R> getParsed<R>(
    String path,
    R Function(String body) parse, {
    Map<String, String>? query,
  }) async {
    final res = await _run(
      (h) => _net.get(_url(path), query: query, headers: h, decodeJson: false),
    );
    if (res.statusCode >= 400) {
      throw KitsuException(
        _errorMessage(_errorBody(res.data), res.statusCode),
        res.statusCode,
      );
    }
    return compute(parse, '${res.data}');
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) =>
      _run(
        (h) => _net.post(_url(path), data: jsonEncode(body), headers: h),
      ).then(_decode);

  Future<Map<String, dynamic>> graphql(
    String query,
    Map<String, dynamic> variables,
  ) => _run(
    (h) => _net.post(
      kitsuGraphqlUrl,
      data: jsonEncode({'query': query, 'variables': variables}),
      headers: {
        ...h,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  ).then(_decode);

  Future<Map<String, dynamic>> patch(String path, Map<String, dynamic> body) =>
      _run(
        (h) => _net.patch(_url(path), data: jsonEncode(body), headers: h),
      ).then(_decode);

  Future<void> delete(String path) async {
    final res = await _run((h) => _net.delete(_url(path), headers: h));
    if (res.statusCode >= 400 && res.statusCode != 404) {
      throw KitsuException(
        _errorMessage(_errorBody(res.data), res.statusCode),
        res.statusCode,
      );
    }
  }
}
