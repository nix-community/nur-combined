// ignore_for_file: type=lint, type=warning
part of 'signals.dart';


@immutable
class UploadTextResponse {
  /// An async broadcast stream that listens for signals from Rust.
  /// It supports multiple subscriptions.
  /// Make sure to cancel the subscription when it's no longer needed,
  /// such as when a widget is disposed.
  static final rustSignalStream =
      _uploadTextResponseStreamController.stream.asBroadcastStream();
        
  /// The latest signal value received from Rust.
  /// This is updated every time a new signal is received.
  /// It can be null if no signals have been received yet.
  static RustSignalPack<UploadTextResponse>? latestRustSignal = null;

  const UploadTextResponse({
    this.url,
    this.error,
  });

  static UploadTextResponse deserialize(BinaryDeserializer deserializer) {
    deserializer.increaseContainerDepth();
    final instance = UploadTextResponse(
      url: TraitHelpers.deserializeOptionStr(deserializer),
      error: TraitHelpers.deserializeOptionStr(deserializer),
    );
    deserializer.decreaseContainerDepth();
    return instance;
  }

  static UploadTextResponse bincodeDeserialize(Uint8List input) {
    final deserializer = BincodeDeserializer(input);
    final value = UploadTextResponse.deserialize(deserializer);
    if (deserializer.offset < input.length) {
      throw Exception('Some input bytes were not read');
    }
    return value;
  }

  final String? url;
  final String? error;

  UploadTextResponse copyWith({
    String? Function()? url,
    String? Function()? error,
  }) {
    return UploadTextResponse(
      url: url == null ? this.url : url(),
      error: error == null ? this.error : error(),
    );
  }

  void serialize(BinarySerializer serializer) {
    serializer.increaseContainerDepth();
    TraitHelpers.serializeOptionStr(url, serializer);
    TraitHelpers.serializeOptionStr(error, serializer);
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

    return other is UploadTextResponse
      && url == other.url
      && error == other.error;
  }

  @override
  int get hashCode => Object.hash(
        url,
        error,
      );

  @override
  String toString() {
    String? fullString;

    assert(() {
      fullString = '$runtimeType('
        'url: $url, '
        'error: $error'
        ')';
      return true;
    }());

    return fullString ?? 'UploadTextResponse';
  }
}

final _uploadTextResponseStreamController =
    StreamController<RustSignalPack<UploadTextResponse>>();
