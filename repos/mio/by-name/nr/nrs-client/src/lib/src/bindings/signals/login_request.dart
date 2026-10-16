// ignore_for_file: type=lint, type=warning
part of 'signals.dart';

@immutable
class LoginRequest {
  const LoginRequest({
    required this.username,
    required this.password,
    this.proxyUrl,
    this.country,
  });

  static LoginRequest deserialize(BinaryDeserializer deserializer) {
    deserializer.increaseContainerDepth();
    final instance = LoginRequest(
      username: deserializer.deserializeString(),
      password: deserializer.deserializeString(),
      proxyUrl: TraitHelpers.deserializeOptionStr(deserializer),
      country: TraitHelpers.deserializeOptionStr(deserializer),
    );
    deserializer.decreaseContainerDepth();
    return instance;
  }

  static LoginRequest bincodeDeserialize(Uint8List input) {
    final deserializer = BincodeDeserializer(input);
    final value = LoginRequest.deserialize(deserializer);
    if (deserializer.offset < input.length) {
      throw Exception('Some input bytes were not read');
    }
    return value;
  }

  final String username;
  final String password;
  final String? proxyUrl;
  final String? country;

  void serialize(BinarySerializer serializer) {
    serializer.increaseContainerDepth();
    serializer.serializeString(username);
    serializer.serializeString(password);
    TraitHelpers.serializeOptionStr(proxyUrl, serializer);
    TraitHelpers.serializeOptionStr(country, serializer);
    serializer.decreaseContainerDepth();
  }

  Uint8List bincodeSerialize() {
    final serializer = BincodeSerializer();
    serialize(serializer);
    return serializer.bytes;
  }
}

extension LoginRequestDartSignalExt on LoginRequest {
  void sendSignalToRust() {
    final messageBytes = bincodeSerialize();
    final binary = Uint8List(0);
    sendDartSignal(
      'rinf_send_dart_signal_login_request',
      messageBytes,
      binary,
    );
  }
}
