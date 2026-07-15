// ignore_for_file: type=lint, type=warning
part of 'signals.dart';


@immutable
class TerminalOutput {
  /// An async broadcast stream that listens for signals from Rust.
  /// It supports multiple subscriptions.
  /// Make sure to cancel the subscription when it's no longer needed,
  /// such as when a widget is disposed.
  static final rustSignalStream =
      _terminalOutputStreamController.stream.asBroadcastStream();
        
  /// The latest signal value received from Rust.
  /// This is updated every time a new signal is received.
  /// It can be null if no signals have been received yet.
  static RustSignalPack<TerminalOutput>? latestRustSignal = null;

  const TerminalOutput({
    required this.sessionId,
    required this.data,
  });

  static TerminalOutput deserialize(BinaryDeserializer deserializer) {
    deserializer.increaseContainerDepth();
    final instance = TerminalOutput(
      sessionId: deserializer.deserializeInt64(),
      data: TraitHelpers.deserializeVectorU8(deserializer),
    );
    deserializer.decreaseContainerDepth();
    return instance;
  }

  static TerminalOutput bincodeDeserialize(Uint8List input) {
    final deserializer = BincodeDeserializer(input);
    final value = TerminalOutput.deserialize(deserializer);
    if (deserializer.offset < input.length) {
      throw Exception('Some input bytes were not read');
    }
    return value;
  }

  final int sessionId;
  final List<int> data;

  TerminalOutput copyWith({
    int? sessionId,
    List<int>? data,
  }) {
    return TerminalOutput(
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

    return other is TerminalOutput
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

    return fullString ?? 'TerminalOutput';
  }
}

final _terminalOutputStreamController =
    StreamController<RustSignalPack<TerminalOutput>>();
