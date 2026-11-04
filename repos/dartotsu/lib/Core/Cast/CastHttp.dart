import 'dart:async';
import 'dart:convert';
import 'dart:io';

final _client = HttpClient()..connectionTimeout = const Duration(seconds: 3);

Future<String?> localAddressToward(String host, int port) async {
  try {
    final socket = await Socket.connect(
      host,
      port,
      timeout: const Duration(seconds: 2),
    );
    final address = socket.address.address;
    socket.destroy();
    return address;
  } catch (_) {
    return null;
  }
}

Future<String?> castGet(String url, {Duration? timeout}) async {
  try {
    final request = await _client.getUrl(Uri.parse(url));
    final reply = await request.close().timeout(
      timeout ?? const Duration(seconds: 3),
    );
    final body = await reply.transform(utf8.decoder).join();
    return reply.statusCode == 200 ? body : null;
  } catch (_) {
    return null;
  }
}

Future<String?> castPost(
  String url, {
  String body = '',
  Map<String, String> headers = const {},
  Duration? timeout,
}) async {
  try {
    final request = await _client.postUrl(Uri.parse(url));
    headers.forEach(request.headers.set);
    request.add(utf8.encode(body));
    final reply = await request.close().timeout(
      timeout ?? const Duration(seconds: 5),
    );
    final text = await reply.transform(utf8.decoder).join();
    return reply.statusCode < 300 ? text : null;
  } catch (_) {
    return null;
  }
}
