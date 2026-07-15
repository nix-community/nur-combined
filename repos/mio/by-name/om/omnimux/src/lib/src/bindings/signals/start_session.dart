// ignore_for_file: type=lint, type=warning
part of 'signals.dart';


@immutable
class StartSession {
  const StartSession({
    required this.sessionId,
    required this.host,
    required this.cols,
    required this.rows,
  });

  static StartSession deserialize(BinaryDeserializer deserializer) {
    deserializer.increaseContainerDepth();
    final instance = StartSession(
      sessionId: deserializer.deserializeInt64(),
      host: deserializer.deserializeString(),
      cols: deserializer.deserializeUint16(),
      rows: deserializer.deserializeUint16(),
    );
    deserializer.decreaseContainerDepth();
    return instance;
  }

  static StartSession bincodeDeserialize(Uint8List input) {
    final deserializer = BincodeDeserializer(input);
    final value = StartSession.deserialize(deserializer);
    if (deserializer.offset < input.length) {
      throw Exception('Some input bytes were not read');
    }
    return value;
  }

  final int sessionId;
  final String host;
  final int cols;
  final int rows;

  StartSession copyWith({
    int? sessionId,
    String? host,
    int? cols,
    int? rows,
  }) {
    return StartSession(
      sessionId: sessionId ?? this.sessionId,
      host: host ?? this.host,
      cols: cols ?? this.cols,
      rows: rows ?? this.rows,
    );
  }

  void serialize(BinarySerializer serializer) {
    serializer.increaseContainerDepth();
    serializer.serializeInt64(sessionId);
    serializer.serializeString(host);
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

    return other is StartSession
      && sessionId == other.sessionId
      && host == other.host
      && cols == other.cols
      && rows == other.rows;
  }

  @override
  int get hashCode => Object.hash(
        sessionId,
        host,
        cols,
        rows,
      );

  @override
  String toString() {
    String? fullString;

    assert(() {
      fullString = '$runtimeType('
        'sessionId: $sessionId, '
        'host: $host, '
        'cols: $cols, '
        'rows: $rows'
        ')';
      return true;
    }());

    return fullString ?? 'StartSession';
  }
}

extension StartSessionDartSignalExt on StartSession {
  /// Sends the signal to Rust.
  /// Passing data from Rust to Dart involves a memory copy
  /// because Rust cannot own data managed by Dart's garbage collector.
  void sendSignalToRust() {
    final messageBytes = bincodeSerialize();
    final binary = Uint8List(0);
    sendDartSignal(
      'rinf_send_dart_signal_start_session',
      messageBytes,
      binary,
    );
  }
}
