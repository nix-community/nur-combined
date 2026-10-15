// ignore_for_file: type=lint, type=warning
part of 'signals.dart';


@immutable
class CallStateSignal {
  /// An async broadcast stream that listens for signals from Rust.
  /// It supports multiple subscriptions.
  /// Make sure to cancel the subscription when it's no longer needed,
  /// such as when a widget is disposed.
  static final rustSignalStream =
      _callStateSignalStreamController.stream.asBroadcastStream();
        
  /// The latest signal value received from Rust.
  /// This is updated every time a new signal is received.
  /// It can be null if no signals have been received yet.
  static RustSignalPack<CallStateSignal>? latestRustSignal = null;

  const CallStateSignal({
    required this.state,
    required this.statusMessage,
    required this.officerBadge,
    required this.recipientNumber,
    required this.durationSeconds,
    this.errorDetail,
  });

  static CallStateSignal deserialize(BinaryDeserializer deserializer) {
    deserializer.increaseContainerDepth();
    final instance = CallStateSignal(
      state: deserializer.deserializeString(),
      statusMessage: deserializer.deserializeString(),
      officerBadge: deserializer.deserializeString(),
      recipientNumber: deserializer.deserializeString(),
      durationSeconds: deserializer.deserializeUint64(),
      errorDetail: TraitHelpers.deserializeOptionStr(deserializer),
    );
    deserializer.decreaseContainerDepth();
    return instance;
  }

  static CallStateSignal bincodeDeserialize(Uint8List input) {
    final deserializer = BincodeDeserializer(input);
    final value = CallStateSignal.deserialize(deserializer);
    if (deserializer.offset < input.length) {
      throw Exception('Some input bytes were not read');
    }
    return value;
  }

  final String state;
  final String statusMessage;
  final String officerBadge;
  final String recipientNumber;
  final Uint64 durationSeconds;
  final String? errorDetail;

  CallStateSignal copyWith({
    String? state,
    String? statusMessage,
    String? officerBadge,
    String? recipientNumber,
    Uint64? durationSeconds,
    String? Function()? errorDetail,
  }) {
    return CallStateSignal(
      state: state ?? this.state,
      statusMessage: statusMessage ?? this.statusMessage,
      officerBadge: officerBadge ?? this.officerBadge,
      recipientNumber: recipientNumber ?? this.recipientNumber,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      errorDetail: errorDetail == null ? this.errorDetail : errorDetail(),
    );
  }

  void serialize(BinarySerializer serializer) {
    serializer.increaseContainerDepth();
    serializer.serializeString(state);
    serializer.serializeString(statusMessage);
    serializer.serializeString(officerBadge);
    serializer.serializeString(recipientNumber);
    serializer.serializeUint64(durationSeconds);
    TraitHelpers.serializeOptionStr(errorDetail, serializer);
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

    return other is CallStateSignal
      && state == other.state
      && statusMessage == other.statusMessage
      && officerBadge == other.officerBadge
      && recipientNumber == other.recipientNumber
      && durationSeconds == other.durationSeconds
      && errorDetail == other.errorDetail;
  }

  @override
  int get hashCode => Object.hash(
        state,
        statusMessage,
        officerBadge,
        recipientNumber,
        durationSeconds,
        errorDetail,
      );

  @override
  String toString() {
    String? fullString;

    assert(() {
      fullString = '$runtimeType('
        'state: $state, '
        'statusMessage: $statusMessage, '
        'officerBadge: $officerBadge, '
        'recipientNumber: $recipientNumber, '
        'durationSeconds: $durationSeconds, '
        'errorDetail: $errorDetail'
        ')';
      return true;
    }());

    return fullString ?? 'CallStateSignal';
  }
}

final _callStateSignalStreamController =
    StreamController<RustSignalPack<CallStateSignal>>();
