import 'dart:io';

import 'package:rhttp/rhttp.dart';

class OfflineGate extends Interceptor {
  static bool on = false;

  static bool isLocal(String url) {
    final host = Uri.tryParse(url)?.host ?? '';
    if (host.isEmpty || host == 'localhost' || host.endsWith('.local')) {
      return true;
    }
    final ip = InternetAddress.tryParse(host);
    if (ip == null) return false;
    if (ip.isLoopback || ip.isLinkLocal) return true;
    final b = ip.rawAddress;
    if (ip.type == InternetAddressType.IPv4) {
      return b[0] == 10 ||
          (b[0] == 172 && b[1] >= 16 && b[1] <= 31) ||
          (b[0] == 192 && b[1] == 168);
    }
    return b[0] & 0xfe == 0xfc;
  }

  @override
  Future<InterceptorResult<HttpRequest>> beforeRequest(
    HttpRequest request,
  ) async {
    if (on && !isLocal(request.url)) {
      throw RhttpConnectionException(request, 'Offline mode');
    }
    return Interceptor.next(request);
  }
}
