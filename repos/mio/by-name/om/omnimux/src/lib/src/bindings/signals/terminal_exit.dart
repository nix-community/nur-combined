// ignore_for_file: type=lint, type=warning
part of 'signals.dart';


@immutable
class TerminalExit {
  /// An async broadcast stream that listens for signals from Rust.
  /// It supports multiple subscriptions.
  /// Make sure to cancel the subscription when it's no longer needed,
  /// such as when a widget is disposed.
  static final rustSignalStream =
      _terminalExitStreamController.stream.asBroadcastStream();
        
  /// The latest signal value received from Rust.
  /// This is updated every time a new signal is received.
  /// It can be null if no signals have been received yet.
  static RustSignalPack<TerminalExit>? latestRustSignal = null;

  const TerminalExit({
    required this.sessionId,
    this.status,
  });

  static TerminalExit deserialize(BinaryDeserializer deserializer) {
    deserializer.increaseContainerDepth();
    final instance = TerminalExit(
      sessionId: deserializer.deserializeInt64(),
      status: TraitHelpers.deserializeOptionI32(deserializer),
    );
    deserializer.decreaseContainerDepth();
    return instance;
  }

  static TerminalExit bincodeDeserialize(Uint8List input) {
    final deserializer = BincodeDeserializer(input);
    final value = TerminalExit.deserialize(deserializer);
    if (deserializer.offset < input.length) {
      throw Exception('Some input bytes were not read');
    }
    return value;
  }

  final int sessionId;
  final int? status;

  TerminalExit copyWith({
    int? sessionId,
    int? Function()? status,
  }) {
    return TerminalExit(
      sessionId: sessionId ?? this.sessionId,
      status: status == null ? this.status : status(),
    );
  }

  void serialize(BinarySerializer serializer) {
    serializer.increaseContainerDepth();
    serializer.serializeInt64(sessionId);
    TraitHelpers.serializeOptionI32(status, serializer);
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

    return other is TerminalExit
      && sessionId == other.sessionId
      && status == other.status;
  }

  @override
  int get hashCode => Object.hash(
        sessionId,
        status,
      );

  @override
  String toString() {
    String? fullString;

    assert(() {
      fullString = '$runtimeType('
        'sessionId: $sessionId, '
        'status: $status'
        ')';
      return true;
    }());

    return fullString ?? 'TerminalExit';
  }
}

final _terminalExitStreamController =
    StreamController<RustSignalPack<TerminalExit>>();
