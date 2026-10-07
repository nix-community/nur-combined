// ignore_for_file: type=lint, type=warning
part of 'signals.dart';


@immutable
class UploadTextRequest {
  const UploadTextRequest({
    required this.text,
  });

  static UploadTextRequest deserialize(BinaryDeserializer deserializer) {
    deserializer.increaseContainerDepth();
    final instance = UploadTextRequest(
      text: deserializer.deserializeString(),
    );
    deserializer.decreaseContainerDepth();
    return instance;
  }

  static UploadTextRequest bincodeDeserialize(Uint8List input) {
    final deserializer = BincodeDeserializer(input);
    final value = UploadTextRequest.deserialize(deserializer);
    if (deserializer.offset < input.length) {
      throw Exception('Some input bytes were not read');
    }
    return value;
  }

  final String text;

  UploadTextRequest copyWith({
    String? text,
  }) {
    return UploadTextRequest(
      text: text ?? this.text,
    );
  }

  void serialize(BinarySerializer serializer) {
    serializer.increaseContainerDepth();
    serializer.serializeString(text);
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

    return other is UploadTextRequest
      && text == other.text;
  }

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() {
    String? fullString;

    assert(() {
      fullString = '$runtimeType('
        'text: $text'
        ')';
      return true;
    }());

    return fullString ?? 'UploadTextRequest';
  }
}

extension UploadTextRequestDartSignalExt on UploadTextRequest {
  /// Sends the signal to Rust.
  /// Passing data from Rust to Dart involves a memory copy
  /// because Rust cannot own data managed by Dart's garbage collector.
  void sendSignalToRust() {
    final messageBytes = bincodeSerialize();
    final binary = Uint8List(0);
    sendDartSignal(
      'rinf_send_dart_signal_upload_text_request',
      messageBytes,
      binary,
    );
  }
}
