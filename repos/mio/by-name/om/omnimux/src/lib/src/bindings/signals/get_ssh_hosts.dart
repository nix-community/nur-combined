// ignore_for_file: type=lint, type=warning
part of 'signals.dart';


@immutable
class GetSshHosts {
  const GetSshHosts(
  );

  static GetSshHosts deserialize(BinaryDeserializer deserializer) {
    deserializer.increaseContainerDepth();
    final instance = GetSshHosts(
    );
    deserializer.decreaseContainerDepth();
    return instance;
  }

  static GetSshHosts bincodeDeserialize(Uint8List input) {
    final deserializer = BincodeDeserializer(input);
    final value = GetSshHosts.deserialize(deserializer);
    if (deserializer.offset < input.length) {
      throw Exception('Some input bytes were not read');
    }
    return value;
  }

  void serialize(BinarySerializer serializer) {
    serializer.increaseContainerDepth();
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

    return other is GetSshHosts;
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    String? fullString;

    assert(() {
      fullString = '$runtimeType('
        ')';
      return true;
    }());

    return fullString ?? 'GetSshHosts';
  }
}

extension GetSshHostsDartSignalExt on GetSshHosts {
  /// Sends the signal to Rust.
  /// Passing data from Rust to Dart involves a memory copy
  /// because Rust cannot own data managed by Dart's garbage collector.
  void sendSignalToRust() {
    final messageBytes = bincodeSerialize();
    final binary = Uint8List(0);
    sendDartSignal(
      'rinf_send_dart_signal_get_ssh_hosts',
      messageBytes,
      binary,
    );
  }
}
