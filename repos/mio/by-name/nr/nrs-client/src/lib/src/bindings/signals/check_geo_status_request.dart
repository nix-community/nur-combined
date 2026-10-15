// ignore_for_file: type=lint, type=warning
part of 'signals.dart';


@immutable
class CheckGeoStatusRequest {
  const CheckGeoStatusRequest({
    this.proxyUrl,
  });

  static CheckGeoStatusRequest deserialize(BinaryDeserializer deserializer) {
    deserializer.increaseContainerDepth();
    final instance = CheckGeoStatusRequest(
      proxyUrl: TraitHelpers.deserializeOptionStr(deserializer),
    );
    deserializer.decreaseContainerDepth();
    return instance;
  }

  static CheckGeoStatusRequest bincodeDeserialize(Uint8List input) {
    final deserializer = BincodeDeserializer(input);
    final value = CheckGeoStatusRequest.deserialize(deserializer);
    if (deserializer.offset < input.length) {
      throw Exception('Some input bytes were not read');
    }
    return value;
  }

  final String? proxyUrl;

  CheckGeoStatusRequest copyWith({
    String? Function()? proxyUrl,
  }) {
    return CheckGeoStatusRequest(
      proxyUrl: proxyUrl == null ? this.proxyUrl : proxyUrl(),
    );
  }

  void serialize(BinarySerializer serializer) {
    serializer.increaseContainerDepth();
    TraitHelpers.serializeOptionStr(proxyUrl, serializer);
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

    return other is CheckGeoStatusRequest
      && proxyUrl == other.proxyUrl;
  }

  @override
  int get hashCode => proxyUrl.hashCode;

  @override
  String toString() {
    String? fullString;

    assert(() {
      fullString = '$runtimeType('
        'proxyUrl: $proxyUrl'
        ')';
      return true;
    }());

    return fullString ?? 'CheckGeoStatusRequest';
  }
}

extension CheckGeoStatusRequestDartSignalExt on CheckGeoStatusRequest {
  /// Sends the signal to Rust.
  /// Passing data from Rust to Dart involves a memory copy
  /// because Rust cannot own data managed by Dart's garbage collector.
  void sendSignalToRust() {
    final messageBytes = bincodeSerialize();
    final binary = Uint8List(0);
    sendDartSignal(
      'rinf_send_dart_signal_check_geo_status_request',
      messageBytes,
      binary,
    );
  }
}
