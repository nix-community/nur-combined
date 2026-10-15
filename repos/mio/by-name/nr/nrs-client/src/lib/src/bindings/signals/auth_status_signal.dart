// ignore_for_file: type=lint, type=warning
part of 'signals.dart';

@immutable
class AuthStatusSignal {
  static final rustSignalStream =
      _authStatusSignalStreamController.stream.asBroadcastStream();

  static RustSignalPack<AuthStatusSignal>? latestRustSignal;

  const AuthStatusSignal({
    required this.isAuthenticated,
    required this.username,
    required this.userToken,
    required this.firstName,
    required this.lastName,
    required this.nrsId,
    this.errorMessage,
  });

  static AuthStatusSignal deserialize(BinaryDeserializer deserializer) {
    deserializer.increaseContainerDepth();
    final instance = AuthStatusSignal(
      isAuthenticated: deserializer.deserializeBool(),
      username: deserializer.deserializeString(),
      userToken: deserializer.deserializeString(),
      firstName: deserializer.deserializeString(),
      lastName: deserializer.deserializeString(),
      nrsId: deserializer.deserializeString(),
      errorMessage: TraitHelpers.deserializeOptionStr(deserializer),
    );
    deserializer.decreaseContainerDepth();
    return instance;
  }

  static AuthStatusSignal bincodeDeserialize(Uint8List input) {
    final deserializer = BincodeDeserializer(input);
    final value = AuthStatusSignal.deserialize(deserializer);
    if (deserializer.offset < input.length) {
      throw Exception('Some input bytes were not read');
    }
    return value;
  }

  final bool isAuthenticated;
  final String username;
  final String userToken;
  final String firstName;
  final String lastName;
  final String nrsId;
  final String? errorMessage;

  void serialize(BinarySerializer serializer) {
    serializer.increaseContainerDepth();
    serializer.serializeBool(isAuthenticated);
    serializer.serializeString(username);
    serializer.serializeString(userToken);
    serializer.serializeString(firstName);
    serializer.serializeString(lastName);
    serializer.serializeString(nrsId);
    TraitHelpers.serializeOptionStr(errorMessage, serializer);
    serializer.decreaseContainerDepth();
  }

  Uint8List bincodeSerialize() {
    final serializer = BincodeSerializer();
    serialize(serializer);
    return serializer.bytes;
  }
}

final _authStatusSignalStreamController =
    StreamController<RustSignalPack<AuthStatusSignal>>();
