// ignore_for_file: type=lint, type=warning
part of 'signals.dart';


@immutable
class StopSession {
  const StopSession({
    required this.sessionId,
  });

  static StopSession deserialize(BinaryDeserializer deserializer) {
    deserializer.increaseContainerDepth();
    final instance = StopSession(
      sessionId: deserializer.deserializeInt64(),
    );
    deserializer.decreaseContainerDepth();
    return instance;
  }

  static StopSession bincodeDeserialize(Uint8List input) {
    final deserializer = BincodeDeserializer(input);
    final value = StopSession.deserialize(deserializer);
    if (deserializer.offset < input.length) {
      throw Exception('Some input bytes were not read');
    }
    return value;
  }

  final int sessionId;

  StopSession copyWith({
    int? sessionId,
  }) {
    return StopSession(
      sessionId: sessionId ?? this.sessionId,
    );
  }

  void serialize(BinarySerializer serializer) {
    serializer.increaseContainerDepth();
    serializer.serializeInt64(sessionId);
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

    return other is StopSession
      && sessionId == other.sessionId;
  }

  @override
  int get hashCode => sessionId.hashCode;

  @override
  String toString() {
    String? fullString;

    assert(() {
      fullString = '$runtimeType('
        'sessionId: $sessionId'
        ')';
      return true;
    }());

    return fullString ?? 'StopSession';
  }
}

extension StopSessionDartSignalExt on StopSession {
  /// Sends the signal to Rust.
  /// Passing data from Rust to Dart involves a memory copy
  /// because Rust cannot own data managed by Dart's garbage collector.
  void sendSignalToRust() {
    final messageBytes = bincodeSerialize();
    final binary = Uint8List(0);
    sendDartSignal(
      'rinf_send_dart_signal_stop_session',
      messageBytes,
      binary,
    );
  }
}
