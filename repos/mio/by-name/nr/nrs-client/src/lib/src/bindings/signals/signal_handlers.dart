part of 'signals.dart';

final assignRustSignal = <String, void Function(Uint8List, Uint8List)>{
  'CallStateSignal': (Uint8List messageBytes, Uint8List binary) {
    final message = CallStateSignal.bincodeDeserialize(messageBytes);
    final rustSignal = RustSignalPack(
      message,
      binary,
    );
    _callStateSignalStreamController.add(rustSignal);
    CallStateSignal.latestRustSignal = rustSignal;
  },
  'GeoStatusSignal': (Uint8List messageBytes, Uint8List binary) {
    final message = GeoStatusSignal.bincodeDeserialize(messageBytes);
    final rustSignal = RustSignalPack(
      message,
      binary,
    );
    _geoStatusSignalStreamController.add(rustSignal);
    GeoStatusSignal.latestRustSignal = rustSignal;
  },
  'RelayMessageSignal': (Uint8List messageBytes, Uint8List binary) {
    final message = RelayMessageSignal.bincodeDeserialize(messageBytes);
    final rustSignal = RustSignalPack(
      message,
      binary,
    );
    _relayMessageSignalStreamController.add(rustSignal);
    RelayMessageSignal.latestRustSignal = rustSignal;
  },
  'TranscriptExportedSignal': (Uint8List messageBytes, Uint8List binary) {
    final message = TranscriptExportedSignal.bincodeDeserialize(messageBytes);
    final rustSignal = RustSignalPack(
      message,
      binary,
    );
    _transcriptExportedSignalStreamController.add(rustSignal);
    TranscriptExportedSignal.latestRustSignal = rustSignal;
  },
};
