// ignore_for_file: type=lint, type=warning
part of 'signals.dart';

/// Upload byte progress for the current provider attempt.
@immutable
class UploadProgress {
  /// An async broadcast stream that listens for signals from Rust.
  /// It supports multiple subscriptions.
  /// Make sure to cancel the subscription when it's no longer needed,
  /// such as when a widget is disposed.
  static final rustSignalStream =
      _uploadProgressStreamController.stream.asBroadcastStream();
        
  /// The latest signal value received from Rust.
  /// This is updated every time a new signal is received.
  /// It can be null if no signals have been received yet.
  static RustSignalPack<UploadProgress>? latestRustSignal = null;

  const UploadProgress({
    required this.bytesSent,
    required this.bytesTotal,
  });

  static UploadProgress deserialize(BinaryDeserializer deserializer) {
    deserializer.increaseContainerDepth();
    final instance = UploadProgress(
      bytesSent: deserializer.deserializeUint64(),
      bytesTotal: deserializer.deserializeUint64(),
    );
    deserializer.decreaseContainerDepth();
    return instance;
  }

  static UploadProgress bincodeDeserialize(Uint8List input) {
    final deserializer = BincodeDeserializer(input);
    final value = UploadProgress.deserialize(deserializer);
    if (deserializer.offset < input.length) {
      throw Exception('Some input bytes were not read');
    }
    return value;
  }

  final Uint64 bytesSent;
  final Uint64 bytesTotal;

  UploadProgress copyWith({
    Uint64? bytesSent,
    Uint64? bytesTotal,
  }) {
    return UploadProgress(
      bytesSent: bytesSent ?? this.bytesSent,
      bytesTotal: bytesTotal ?? this.bytesTotal,
    );
  }

  void serialize(BinarySerializer serializer) {
    serializer.increaseContainerDepth();
    serializer.serializeUint64(bytesSent);
    serializer.serializeUint64(bytesTotal);
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

    return other is UploadProgress
      && bytesSent == other.bytesSent
      && bytesTotal == other.bytesTotal;
  }

  @override
  int get hashCode => Object.hash(
        bytesSent,
        bytesTotal,
      );

  @override
  String toString() {
    String? fullString;

    assert(() {
      fullString = '$runtimeType('
        'bytesSent: $bytesSent, '
        'bytesTotal: $bytesTotal'
        ')';
      return true;
    }());

    return fullString ?? 'UploadProgress';
  }
}

final _uploadProgressStreamController =
    StreamController<RustSignalPack<UploadProgress>>();
