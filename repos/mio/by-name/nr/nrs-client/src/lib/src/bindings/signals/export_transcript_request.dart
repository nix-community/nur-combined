// ignore_for_file: type=lint, type=warning
part of 'signals.dart';


@immutable
class ExportTranscriptRequest {
  const ExportTranscriptRequest({
    required this.format,
  });

  static ExportTranscriptRequest deserialize(BinaryDeserializer deserializer) {
    deserializer.increaseContainerDepth();
    final instance = ExportTranscriptRequest(
      format: deserializer.deserializeString(),
    );
    deserializer.decreaseContainerDepth();
    return instance;
  }

  static ExportTranscriptRequest bincodeDeserialize(Uint8List input) {
    final deserializer = BincodeDeserializer(input);
    final value = ExportTranscriptRequest.deserialize(deserializer);
    if (deserializer.offset < input.length) {
      throw Exception('Some input bytes were not read');
    }
    return value;
  }

  final String format;

  ExportTranscriptRequest copyWith({
    String? format,
  }) {
    return ExportTranscriptRequest(
      format: format ?? this.format,
    );
  }

  void serialize(BinarySerializer serializer) {
    serializer.increaseContainerDepth();
    serializer.serializeString(format);
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

    return other is ExportTranscriptRequest
      && format == other.format;
  }

  @override
  int get hashCode => format.hashCode;

  @override
  String toString() {
    String? fullString;

    assert(() {
      fullString = '$runtimeType('
        'format: $format'
        ')';
      return true;
    }());

    return fullString ?? 'ExportTranscriptRequest';
  }
}

extension ExportTranscriptRequestDartSignalExt on ExportTranscriptRequest {
  /// Sends the signal to Rust.
  /// Passing data from Rust to Dart involves a memory copy
  /// because Rust cannot own data managed by Dart's garbage collector.
  void sendSignalToRust() {
    final messageBytes = bincodeSerialize();
    final binary = Uint8List(0);
    sendDartSignal(
      'rinf_send_dart_signal_export_transcript_request',
      messageBytes,
      binary,
    );
  }
}
