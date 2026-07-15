// ignore_for_file: type=lint, type=warning
part of 'signals.dart';


@immutable
class WriteSession {
  const WriteSession({
    required this.sessionId,
    required this.data,
  });

  static WriteSession deserialize(BinaryDeserializer deserializer) {
    deserializer.increaseContainerDepth();
    final instance = WriteSession(
      sessionId: deserializer.deserializeInt64(),
      data: TraitHelpers.deserializeVectorU8(deserializer),
    );
    deserializer.decreaseContainerDepth();
    return instance;
  }

  static WriteSession bincodeDeserialize(Uint8List input) {
    final deserializer = BincodeDeserializer(input);
    final value = WriteSession.deserialize(deserializer);
    if (deserializer.offset < input.length) {
      throw Exception('Some input bytes were not read');
    }
    return value;
  }

  final int sessionId;
  final List<int> data;

  WriteSession copyWith({
    int? sessionId,
    List<int>? data,
  }) {
    return WriteSession(
      sessionId: sessionId ?? this.sessionId,
      data: data ?? this.data,
    );
  }

  void serialize(BinarySerializer serializer) {
    serializer.increaseContainerDepth();
    serializer.serializeInt64(sessionId);
    TraitHelpers.serializeVectorU8(data, serializer);
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

    return other is WriteSession
      && sessionId == other.sessionId
      && listEquals(data, other.data);
  }

  @override
  int get hashCode => Object.hash(
        sessionId,
        data,
      );

  @override
  String toString() {
    String? fullString;

    assert(() {
      fullString = '$runtimeType('
        'sessionId: $sessionId, '
        'data: $data'
        ')';
      return true;
    }());

    return fullString ?? 'WriteSession';
  }
}

extension WriteSessionDartSignalExt on WriteSession {
  /// Sends the signal to Rust.
  /// Passing data from Rust to Dart involves a memory copy
  /// because Rust cannot own data managed by Dart's garbage collector.
  void sendSignalToRust() {
    final messageBytes = bincodeSerialize();
    final binary = Uint8List(0);
    sendDartSignal(
      'rinf_send_dart_signal_write_session',
      messageBytes,
      binary,
    );
  }
}
