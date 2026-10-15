// ignore_for_file: type=lint, type=warning
part of 'signals.dart';


@immutable
class TranscriptExportedSignal {
  /// An async broadcast stream that listens for signals from Rust.
  /// It supports multiple subscriptions.
  /// Make sure to cancel the subscription when it's no longer needed,
  /// such as when a widget is disposed.
  static final rustSignalStream =
      _transcriptExportedSignalStreamController.stream.asBroadcastStream();
        
  /// The latest signal value received from Rust.
  /// This is updated every time a new signal is received.
  /// It can be null if no signals have been received yet.
  static RustSignalPack<TranscriptExportedSignal>? latestRustSignal = null;

  const TranscriptExportedSignal({
    required this.success,
    required this.filename,
    required this.content,
    required this.message,
  });

  static TranscriptExportedSignal deserialize(BinaryDeserializer deserializer) {
    deserializer.increaseContainerDepth();
    final instance = TranscriptExportedSignal(
      success: deserializer.deserializeBool(),
      filename: deserializer.deserializeString(),
      content: deserializer.deserializeString(),
      message: deserializer.deserializeString(),
    );
    deserializer.decreaseContainerDepth();
    return instance;
  }

  static TranscriptExportedSignal bincodeDeserialize(Uint8List input) {
    final deserializer = BincodeDeserializer(input);
    final value = TranscriptExportedSignal.deserialize(deserializer);
    if (deserializer.offset < input.length) {
      throw Exception('Some input bytes were not read');
    }
    return value;
  }

  final bool success;
  final String filename;
  final String content;
  final String message;

  TranscriptExportedSignal copyWith({
    bool? success,
    String? filename,
    String? content,
    String? message,
  }) {
    return TranscriptExportedSignal(
      success: success ?? this.success,
      filename: filename ?? this.filename,
      content: content ?? this.content,
      message: message ?? this.message,
    );
  }

  void serialize(BinarySerializer serializer) {
    serializer.increaseContainerDepth();
    serializer.serializeBool(success);
    serializer.serializeString(filename);
    serializer.serializeString(content);
    serializer.serializeString(message);
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

    return other is TranscriptExportedSignal
      && success == other.success
      && filename == other.filename
      && content == other.content
      && message == other.message;
  }

  @override
  int get hashCode => Object.hash(
        success,
        filename,
        content,
        message,
      );

  @override
  String toString() {
    String? fullString;

    assert(() {
      fullString = '$runtimeType('
        'success: $success, '
        'filename: $filename, '
        'content: $content, '
        'message: $message'
        ')';
      return true;
    }());

    return fullString ?? 'TranscriptExportedSignal';
  }
}

final _transcriptExportedSignalStreamController =
    StreamController<RustSignalPack<TranscriptExportedSignal>>();
