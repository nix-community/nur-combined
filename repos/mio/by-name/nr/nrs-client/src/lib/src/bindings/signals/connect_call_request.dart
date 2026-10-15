// ignore_for_file: type=lint, type=warning
part of 'signals.dart';


@immutable
class ConnectCallRequest {
  const ConnectCallRequest({
    required this.callerName,
    required this.callerPhone,
    required this.recipientPhone,
    required this.callNotes,
    this.proxyUrl,
    required this.australianState,
  });

  static ConnectCallRequest deserialize(BinaryDeserializer deserializer) {
    deserializer.increaseContainerDepth();
    final instance = ConnectCallRequest(
      callerName: deserializer.deserializeString(),
      callerPhone: deserializer.deserializeString(),
      recipientPhone: deserializer.deserializeString(),
      callNotes: deserializer.deserializeString(),
      proxyUrl: TraitHelpers.deserializeOptionStr(deserializer),
      australianState: deserializer.deserializeString(),
    );
    deserializer.decreaseContainerDepth();
    return instance;
  }

  static ConnectCallRequest bincodeDeserialize(Uint8List input) {
    final deserializer = BincodeDeserializer(input);
    final value = ConnectCallRequest.deserialize(deserializer);
    if (deserializer.offset < input.length) {
      throw Exception('Some input bytes were not read');
    }
    return value;
  }

  final String callerName;
  final String callerPhone;
  final String recipientPhone;
  final String callNotes;
  final String? proxyUrl;
  final String australianState;

  ConnectCallRequest copyWith({
    String? callerName,
    String? callerPhone,
    String? recipientPhone,
    String? callNotes,
    String? Function()? proxyUrl,
    String? australianState,
  }) {
    return ConnectCallRequest(
      callerName: callerName ?? this.callerName,
      callerPhone: callerPhone ?? this.callerPhone,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      callNotes: callNotes ?? this.callNotes,
      proxyUrl: proxyUrl == null ? this.proxyUrl : proxyUrl(),
      australianState: australianState ?? this.australianState,
    );
  }

  void serialize(BinarySerializer serializer) {
    serializer.increaseContainerDepth();
    serializer.serializeString(callerName);
    serializer.serializeString(callerPhone);
    serializer.serializeString(recipientPhone);
    serializer.serializeString(callNotes);
    TraitHelpers.serializeOptionStr(proxyUrl, serializer);
    serializer.serializeString(australianState);
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

    return other is ConnectCallRequest
      && callerName == other.callerName
      && callerPhone == other.callerPhone
      && recipientPhone == other.recipientPhone
      && callNotes == other.callNotes
      && proxyUrl == other.proxyUrl
      && australianState == other.australianState;
  }

  @override
  int get hashCode => Object.hash(
        callerName,
        callerPhone,
        recipientPhone,
        callNotes,
        proxyUrl,
        australianState,
      );

  @override
  String toString() {
    String? fullString;

    assert(() {
      fullString = '$runtimeType('
        'callerName: $callerName, '
        'callerPhone: $callerPhone, '
        'recipientPhone: $recipientPhone, '
        'callNotes: $callNotes, '
        'proxyUrl: $proxyUrl, '
        'australianState: $australianState'
        ')';
      return true;
    }());

    return fullString ?? 'ConnectCallRequest';
  }
}

extension ConnectCallRequestDartSignalExt on ConnectCallRequest {
  /// Sends the signal to Rust.
  /// Passing data from Rust to Dart involves a memory copy
  /// because Rust cannot own data managed by Dart's garbage collector.
  void sendSignalToRust() {
    final messageBytes = bincodeSerialize();
    final binary = Uint8List(0);
    sendDartSignal(
      'rinf_send_dart_signal_connect_call_request',
      messageBytes,
      binary,
    );
  }
}
