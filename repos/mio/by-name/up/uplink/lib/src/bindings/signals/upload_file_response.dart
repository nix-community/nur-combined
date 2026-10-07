// ignore_for_file: type=lint, type=warning
part of 'signals.dart';


@immutable
class UploadFileResponse {
  /// An async broadcast stream that listens for signals from Rust.
  /// It supports multiple subscriptions.
  /// Make sure to cancel the subscription when it's no longer needed,
  /// such as when a widget is disposed.
  static final rustSignalStream =
      _uploadFileResponseStreamController.stream.asBroadcastStream();
        
  /// The latest signal value received from Rust.
  /// This is updated every time a new signal is received.
  /// It can be null if no signals have been received yet.
  static RustSignalPack<UploadFileResponse>? latestRustSignal = null;

  const UploadFileResponse({
    this.url,
    this.error,
  });

  static UploadFileResponse deserialize(BinaryDeserializer deserializer) {
    deserializer.increaseContainerDepth();
    final instance = UploadFileResponse(
      url: TraitHelpers.deserializeOptionStr(deserializer),
      error: TraitHelpers.deserializeOptionStr(deserializer),
    );
    deserializer.decreaseContainerDepth();
    return instance;
  }

  static UploadFileResponse bincodeDeserialize(Uint8List input) {
    final deserializer = BincodeDeserializer(input);
    final value = UploadFileResponse.deserialize(deserializer);
    if (deserializer.offset < input.length) {
      throw Exception('Some input bytes were not read');
    }
    return value;
  }

  final String? url;
  final String? error;

  UploadFileResponse copyWith({
    String? Function()? url,
    String? Function()? error,
  }) {
    return UploadFileResponse(
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

    return other is UploadFileResponse
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

    return fullString ?? 'UploadFileResponse';
  }
}

final _uploadFileResponseStreamController =
    StreamController<RustSignalPack<UploadFileResponse>>();
