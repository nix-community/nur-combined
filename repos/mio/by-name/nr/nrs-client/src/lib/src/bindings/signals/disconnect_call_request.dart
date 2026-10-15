// ignore_for_file: type=lint, type=warning
part of 'signals.dart';


@immutable
class DisconnectCallRequest {
  const DisconnectCallRequest({
    required this.reason,
  });

  static DisconnectCallRequest deserialize(BinaryDeserializer deserializer) {
    deserializer.increaseContainerDepth();
    final instance = DisconnectCallRequest(
      reason: deserializer.deserializeString(),
    );
    deserializer.decreaseContainerDepth();
    return instance;
  }

  static DisconnectCallRequest bincodeDeserialize(Uint8List input) {
    final deserializer = BincodeDeserializer(input);
    final value = DisconnectCallRequest.deserialize(deserializer);
    if (deserializer.offset < input.length) {
      throw Exception('Some input bytes were not read');
    }
    return value;
  }

  final String reason;

  DisconnectCallRequest copyWith({
    String? reason,
  }) {
    return DisconnectCallRequest(
      reason: reason ?? this.reason,
    );
  }

  void serialize(BinarySerializer serializer) {
    serializer.increaseContainerDepth();
    serializer.serializeString(reason);
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

    return other is DisconnectCallRequest
      && reason == other.reason;
  }

  @override
  int get hashCode => reason.hashCode;

  @override
  String toString() {
    String? fullString;

    assert(() {
      fullString = '$runtimeType('
        'reason: $reason'
        ')';
      return true;
    }());

    return fullString ?? 'DisconnectCallRequest';
  }
}

extension DisconnectCallRequestDartSignalExt on DisconnectCallRequest {
  /// Sends the signal to Rust.
  /// Passing data from Rust to Dart involves a memory copy
  /// because Rust cannot own data managed by Dart's garbage collector.
  void sendSignalToRust() {
    final messageBytes = bincodeSerialize();
    final binary = Uint8List(0);
    sendDartSignal(
      'rinf_send_dart_signal_disconnect_call_request',
      messageBytes,
      binary,
    );
  }
}
