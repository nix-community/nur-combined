// ignore_for_file: type=lint, type=warning
part of 'signals.dart';


@immutable
class RelayMessageSignal {
  /// An async broadcast stream that listens for signals from Rust.
  /// It supports multiple subscriptions.
  /// Make sure to cancel the subscription when it's no longer needed,
  /// such as when a widget is disposed.
  static final rustSignalStream =
      _relayMessageSignalStreamController.stream.asBroadcastStream();
        
  /// The latest signal value received from Rust.
  /// This is updated every time a new signal is received.
  /// It can be null if no signals have been received yet.
  static RustSignalPack<RelayMessageSignal>? latestRustSignal = null;

  const RelayMessageSignal({
    required this.id,
    required this.timestamp,
    required this.sender,
    required this.content,
    required this.hasGa,
  });

  static RelayMessageSignal deserialize(BinaryDeserializer deserializer) {
    deserializer.increaseContainerDepth();
    final instance = RelayMessageSignal(
      id: deserializer.deserializeString(),
      timestamp: deserializer.deserializeString(),
      sender: deserializer.deserializeString(),
      content: deserializer.deserializeString(),
      hasGa: deserializer.deserializeBool(),
    );
    deserializer.decreaseContainerDepth();
    return instance;
  }

  static RelayMessageSignal bincodeDeserialize(Uint8List input) {
    final deserializer = BincodeDeserializer(input);
    final value = RelayMessageSignal.deserialize(deserializer);
    if (deserializer.offset < input.length) {
      throw Exception('Some input bytes were not read');
    }
    return value;
  }

  final String id;
  final String timestamp;
  final String sender;
  final String content;
  final bool hasGa;

  RelayMessageSignal copyWith({
    String? id,
    String? timestamp,
    String? sender,
    String? content,
    bool? hasGa,
  }) {
    return RelayMessageSignal(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      hasGa: hasGa ?? this.hasGa,
    );
  }

  void serialize(BinarySerializer serializer) {
    serializer.increaseContainerDepth();
    serializer.serializeString(id);
    serializer.serializeString(timestamp);
    serializer.serializeString(sender);
    serializer.serializeString(content);
    serializer.serializeBool(hasGa);
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

    return other is RelayMessageSignal
      && id == other.id
      && timestamp == other.timestamp
      && sender == other.sender
      && content == other.content
      && hasGa == other.hasGa;
  }

  @override
  int get hashCode => Object.hash(
        id,
        timestamp,
        sender,
        content,
        hasGa,
      );

  @override
  String toString() {
    String? fullString;

    assert(() {
      fullString = '$runtimeType('
        'id: $id, '
        'timestamp: $timestamp, '
        'sender: $sender, '
        'content: $content, '
        'hasGa: $hasGa'
        ')';
      return true;
    }());

    return fullString ?? 'RelayMessageSignal';
  }
}

final _relayMessageSignalStreamController =
    StreamController<RustSignalPack<RelayMessageSignal>>();
