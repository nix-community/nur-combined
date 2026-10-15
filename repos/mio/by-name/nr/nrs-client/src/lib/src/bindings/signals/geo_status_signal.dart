// ignore_for_file: type=lint, type=warning
part of 'signals.dart';


@immutable
class GeoStatusSignal {
  /// An async broadcast stream that listens for signals from Rust.
  /// It supports multiple subscriptions.
  /// Make sure to cancel the subscription when it's no longer needed,
  /// such as when a widget is disposed.
  static final rustSignalStream =
      _geoStatusSignalStreamController.stream.asBroadcastStream();
        
  /// The latest signal value received from Rust.
  /// This is updated every time a new signal is received.
  /// It can be null if no signals have been received yet.
  static RustSignalPack<GeoStatusSignal>? latestRustSignal = null;

  const GeoStatusSignal({
    required this.status,
    required this.detectedIp,
    required this.country,
    required this.details,
  });

  static GeoStatusSignal deserialize(BinaryDeserializer deserializer) {
    deserializer.increaseContainerDepth();
    final instance = GeoStatusSignal(
      status: deserializer.deserializeString(),
      detectedIp: deserializer.deserializeString(),
      country: deserializer.deserializeString(),
      details: deserializer.deserializeString(),
    );
    deserializer.decreaseContainerDepth();
    return instance;
  }

  static GeoStatusSignal bincodeDeserialize(Uint8List input) {
    final deserializer = BincodeDeserializer(input);
    final value = GeoStatusSignal.deserialize(deserializer);
    if (deserializer.offset < input.length) {
      throw Exception('Some input bytes were not read');
    }
    return value;
  }

  final String status;
  final String detectedIp;
  final String country;
  final String details;

  GeoStatusSignal copyWith({
    String? status,
    String? detectedIp,
    String? country,
    String? details,
  }) {
    return GeoStatusSignal(
      status: status ?? this.status,
      detectedIp: detectedIp ?? this.detectedIp,
      country: country ?? this.country,
      details: details ?? this.details,
    );
  }

  void serialize(BinarySerializer serializer) {
    serializer.increaseContainerDepth();
    serializer.serializeString(status);
    serializer.serializeString(detectedIp);
    serializer.serializeString(country);
    serializer.serializeString(details);
    serializer.decreaseContainerDepth();
  }

  Uint8List bincodeSerialize() {
      final serializer = BincodeSerializer();
      serialize(serializer);
      return serializer.bytes;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;

    return other is GeoStatusSignal
      && status == other.status
      && detectedIp == other.detectedIp
      && country == other.country
      && details == other.details;
  }

  @override
  int get hashCode => Object.hash(
        status,
        detectedIp,
        country,
        details,
      );

  @override
  String toString() {
    String? fullString;

    assert(() {
      fullString = '$runtimeType('
        'status: $status, '
        'detectedIp: $detectedIp, '
        'country: $country, '
        'details: $details'
        ')';
      return true;
    }());

    return fullString ?? 'GeoStatusSignal';
  }
}

final _geoStatusSignalStreamController =
    StreamController<RustSignalPack<GeoStatusSignal>>();
