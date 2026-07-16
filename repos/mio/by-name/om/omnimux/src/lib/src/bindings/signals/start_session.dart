// ignore_for_file: type=lint, type=warning
part of 'signals.dart';


@immutable
class StartSession {
  final int sessionId;
  final String host;
  final int cols;
  final int rows;
  final bool enableTmuxMouse;

  const StartSession({
    required this.sessionId,
    required this.host,
    required this.cols,
    required this.rows,
    required this.enableTmuxMouse,
  });

  static StartSession deserialize(BinaryDeserializer deserializer) {
    deserializer.increaseContainerDepth();
    final instance = StartSession(
      sessionId: deserializer.deserializeInt64(),
      host: deserializer.deserializeString(),
      cols: deserializer.deserializeUint16(),
      rows: deserializer.deserializeUint16(),
      enableTmuxMouse: deserializer.deserializeBool(),
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

  StartSession copyWith({
    int? sessionId,
    String? host,
    int? cols,
    int? rows,
    bool? enableTmuxMouse,
  }) {
    return StartSession(
      sessionId: sessionId ?? this.sessionId,
      host: host ?? this.host,
      cols: cols ?? this.cols,
      rows: rows ?? this.rows,
      enableTmuxMouse: enableTmuxMouse ?? this.enableTmuxMouse,
    );
  }

  void serialize(BinarySerializer serializer) {
    serializer.increaseContainerDepth();
    serializer.serializeInt64(sessionId);
    serializer.serializeString(host);
    serializer.serializeUint16(cols);
    serializer.serializeUint16(rows);
    serializer.serializeBool(enableTmuxMouse);
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
      && rows == other.rows
      && enableTmuxMouse == other.enableTmuxMouse;
  }

  @override
  int get hashCode => Object.hash(
        sessionId,
        host,
        cols,
        rows,
        enableTmuxMouse,
      );

  @override
  String toString() {
    String? fullString;

    assert(() {
      fullString = '$runtimeType('
        'sessionId: $sessionId, '
        'host: $host, '
        'cols: $cols, '
        'rows: $rows, '
        'enableTmuxMouse: $enableTmuxMouse'
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
