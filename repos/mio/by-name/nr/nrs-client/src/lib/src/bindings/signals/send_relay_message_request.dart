// ignore_for_file: type=lint, type=warning
part of 'signals.dart';


@immutable
class SendRelayMessageRequest {
  const SendRelayMessageRequest({
    required this.text,
    required this.appendGa,
  });

  static SendRelayMessageRequest deserialize(BinaryDeserializer deserializer) {
    deserializer.increaseContainerDepth();
    final instance = SendRelayMessageRequest(
      text: deserializer.deserializeString(),
      appendGa: deserializer.deserializeBool(),
    );
    deserializer.decreaseContainerDepth();
    return instance;
  }

  static SendRelayMessageRequest bincodeDeserialize(Uint8List input) {
    final deserializer = BincodeDeserializer(input);
    final value = SendRelayMessageRequest.deserialize(deserializer);
    if (deserializer.offset < input.length) {
      throw Exception('Some input bytes were not read');
    }
    return value;
  }

  final String text;
  final bool appendGa;

  SendRelayMessageRequest copyWith({
    String? text,
    bool? appendGa,
  }) {
    return SendRelayMessageRequest(
      text: text ?? this.text,
      appendGa: appendGa ?? this.appendGa,
    );
  }

  void serialize(BinarySerializer serializer) {
    serializer.increaseContainerDepth();
    serializer.serializeString(text);
    serializer.serializeBool(appendGa);
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

    return other is SendRelayMessageRequest
      && text == other.text
      && appendGa == other.appendGa;
  }

  @override
  int get hashCode => Object.hash(
        text,
        appendGa,
      );

  @override
  String toString() {
    String? fullString;

    assert(() {
      fullString = '$runtimeType('
        'text: $text, '
        'appendGa: $appendGa'
        ')';
      return true;
    }());

    return fullString ?? 'SendRelayMessageRequest';
  }
}

extension SendRelayMessageRequestDartSignalExt on SendRelayMessageRequest {
  /// Sends the signal to Rust.
  /// Passing data from Rust to Dart involves a memory copy
  /// because Rust cannot own data managed by Dart's garbage collector.
  void sendSignalToRust() {
    final messageBytes = bincodeSerialize();
    final binary = Uint8List(0);
    sendDartSignal(
      'rinf_send_dart_signal_send_relay_message_request',
      messageBytes,
      binary,
    );
  }
}
