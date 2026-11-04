enum CastProtocol { chromecast, dlna, roku }

class CastDevice {
  final String id;
  final String name;
  final String host;
  final int port;
  final CastProtocol protocol;
  final String? controlUrl;
  final String? volumeUrl;

  const CastDevice({
    required this.id,
    required this.name,
    required this.host,
    required this.port,
    required this.protocol,
    this.controlUrl,
    this.volumeUrl,
  });
}
