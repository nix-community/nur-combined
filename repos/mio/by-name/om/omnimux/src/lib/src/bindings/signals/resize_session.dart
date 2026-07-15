// ignore_for_file: type=lint, type=warning
part of 'signals.dart';


@immutable
class ResizeSession {
  const ResizeSession({
    required this.sessionId,
    required this.cols,
    required this.rows,
  });

  static ResizeSession deserialize(BinaryDeserializer deserializer) {
    deserializer.increaseContainerDepth();
    final instance = ResizeSession(
      sessionId: deserializer.deserializeInt64(),
      cols: deserializer.deserializeUint16(),
      rows: deserializer.deserializeUint16(),
    );
    deserializer.decreaseContainerDepth();
    return instance;
  }

  static ResizeSession bincodeDeserialize(Uint8List input) {
    final deserializer = BincodeDeserializer(input);
    final value = ResizeSession.deserialize(deserializer);
    if (deserializer.offset < input.length) {
      throw Exception('Some input bytes were not read');
    }
    return value;
  }

  final int sessionId;
  final int cols;
  final int rows;

  ResizeSession copyWith({
    int? sessionId,
    int? cols,
    int? rows,
  }) {
    return ResizeSession(
      sessionId: sessionId ?? this.sessionId,
      cols: cols ?? this.cols,
      rows: rows ?? this.rows,
    );
  }

  void serialize(BinarySerializer serializer) {
    serializer.increaseContainerDepth();
    serializer.serializeInt64(sessionId);
    serializer.serializeUint16(cols);
    serializer.serializeUint16(rows);
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

    return other is ResizeSession
      && sessionId == other.sessionId
      && cols == other.cols
      && rows == other.rows;
  }

  @override
  int get hashCode => Object.hash(
        sessionId,
        cols,
        rows,
      );

  @override
  String toString() {
    String? fullString;

    assert(() {
      fullString = '$runtimeType('
        'sessionId: $sessionId, '
        'cols: $cols, '
        'rows: $rows'
        ')';
      return true;
    }());

    return fullString ?? 'ResizeSession';
  }
}

extension ResizeSessionDartSignalExt on ResizeSession {
  /// Sends the signal to Rust.
  /// Passing data from Rust to Dart involves a memory copy
  /// because Rust cannot own data managed by Dart's garbage collector.
  void sendSignalToRust() {
    final messageBytes = bincodeSerialize();
    final binary = Uint8List(0);
    sendDartSignal(
      'rinf_send_dart_signal_resize_session',
      messageBytes,
      binary,
    );
  }
}
