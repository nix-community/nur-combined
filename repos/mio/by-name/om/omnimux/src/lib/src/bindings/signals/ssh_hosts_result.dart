// ignore_for_file: type=lint, type=warning
part of 'signals.dart';


@immutable
class SshHostsResult {
  /// An async broadcast stream that listens for signals from Rust.
  /// It supports multiple subscriptions.
  /// Make sure to cancel the subscription when it's no longer needed,
  /// such as when a widget is disposed.
  static final rustSignalStream =
      _sshHostsResultStreamController.stream.asBroadcastStream();
        
  /// The latest signal value received from Rust.
  /// This is updated every time a new signal is received.
  /// It can be null if no signals have been received yet.
  static RustSignalPack<SshHostsResult>? latestRustSignal = null;

  const SshHostsResult({
    required this.hosts,
  });

  static SshHostsResult deserialize(BinaryDeserializer deserializer) {
    deserializer.increaseContainerDepth();
    final instance = SshHostsResult(
      hosts: TraitHelpers.deserializeVectorStr(deserializer),
    );
    deserializer.decreaseContainerDepth();
    return instance;
  }

  static SshHostsResult bincodeDeserialize(Uint8List input) {
    final deserializer = BincodeDeserializer(input);
    final value = SshHostsResult.deserialize(deserializer);
    if (deserializer.offset < input.length) {
      throw Exception('Some input bytes were not read');
    }
    return value;
  }

  final List<String> hosts;

  SshHostsResult copyWith({
    List<String>? hosts,
  }) {
    return SshHostsResult(
      hosts: hosts ?? this.hosts,
    );
  }

  void serialize(BinarySerializer serializer) {
    serializer.increaseContainerDepth();
    TraitHelpers.serializeVectorStr(hosts, serializer);
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

    return other is SshHostsResult
      && listEquals(hosts, other.hosts);
  }

  @override
  int get hashCode => hosts.hashCode;

  @override
  String toString() {
    String? fullString;

    assert(() {
      fullString = '$runtimeType('
        'hosts: $hosts'
        ')';
      return true;
    }());

    return fullString ?? 'SshHostsResult';
  }
}

final _sshHostsResultStreamController =
    StreamController<RustSignalPack<SshHostsResult>>();
