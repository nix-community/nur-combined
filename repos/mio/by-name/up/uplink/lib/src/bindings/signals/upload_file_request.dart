// ignore_for_file: type=lint, type=warning
part of 'signals.dart';


@immutable
class UploadFileRequest {
  const UploadFileRequest({
    required this.filename,
  });

  static UploadFileRequest deserialize(BinaryDeserializer deserializer) {
    deserializer.increaseContainerDepth();
    final instance = UploadFileRequest(
      filename: deserializer.deserializeString(),
    );
    deserializer.decreaseContainerDepth();
    return instance;
  }

  static UploadFileRequest bincodeDeserialize(Uint8List input) {
    final deserializer = BincodeDeserializer(input);
    final value = UploadFileRequest.deserialize(deserializer);
    if (deserializer.offset < input.length) {
      throw Exception('Some input bytes were not read');
    }
    return value;
  }

  final String filename;

  UploadFileRequest copyWith({
    String? filename,
  }) {
    return UploadFileRequest(
      filename: filename ?? this.filename,
    );
  }

  void serialize(BinarySerializer serializer) {
    serializer.increaseContainerDepth();
    serializer.serializeString(filename);
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

    return other is UploadFileRequest
      && filename == other.filename;
  }

  @override
  int get hashCode => filename.hashCode;

  @override
  String toString() {
    String? fullString;

    assert(() {
      fullString = '$runtimeType('
        'filename: $filename'
        ')';
      return true;
    }());

    return fullString ?? 'UploadFileRequest';
  }
}

extension UploadFileRequestDartSignalExt on UploadFileRequest {
  /// Sends the signal to Rust with separate binary data.
  /// Passing data from Rust to Dart involves a memory copy
  /// because Rust cannot own data managed by Dart's garbage collector.
  void sendSignalToRust(Uint8List binary) {
    final messageBytes = bincodeSerialize();
    sendDartSignal(
      'rinf_send_dart_signal_upload_file_request',
      messageBytes,
      binary,
    );
  }
}
