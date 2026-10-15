// ignore_for_file: type=lint, type=warning
part of 'signals.dart';


@immutable
class QuickActionRequest {
  const QuickActionRequest({
    required this.actionType,
  });

  static QuickActionRequest deserialize(BinaryDeserializer deserializer) {
    deserializer.increaseContainerDepth();
    final instance = QuickActionRequest(
      actionType: deserializer.deserializeString(),
    );
    deserializer.decreaseContainerDepth();
    return instance;
  }

  static QuickActionRequest bincodeDeserialize(Uint8List input) {
    final deserializer = BincodeDeserializer(input);
    final value = QuickActionRequest.deserialize(deserializer);
    if (deserializer.offset < input.length) {
      throw Exception('Some input bytes were not read');
    }
    return value;
  }

  final String actionType;

  QuickActionRequest copyWith({
    String? actionType,
  }) {
    return QuickActionRequest(
      actionType: actionType ?? this.actionType,
    );
  }

  void serialize(BinarySerializer serializer) {
    serializer.increaseContainerDepth();
    serializer.serializeString(actionType);
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

    return other is QuickActionRequest
      && actionType == other.actionType;
  }

  @override
  int get hashCode => actionType.hashCode;

  @override
  String toString() {
    String? fullString;

    assert(() {
      fullString = '$runtimeType('
        'actionType: $actionType'
        ')';
      return true;
    }());

    return fullString ?? 'QuickActionRequest';
  }
}

extension QuickActionRequestDartSignalExt on QuickActionRequest {
  /// Sends the signal to Rust.
  /// Passing data from Rust to Dart involves a memory copy
  /// because Rust cannot own data managed by Dart's garbage collector.
  void sendSignalToRust() {
    final messageBytes = bincodeSerialize();
    final binary = Uint8List(0);
    sendDartSignal(
      'rinf_send_dart_signal_quick_action_request',
      messageBytes,
      binary,
    );
  }
}
