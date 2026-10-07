part of 'signals.dart';

final assignRustSignal = <String, void Function(Uint8List, Uint8List)>{
  'UploadFileResponse': (Uint8List messageBytes, Uint8List binary) {
    final message = UploadFileResponse.bincodeDeserialize(messageBytes);
    final rustSignal = RustSignalPack(
      message,
      binary,
    );
    _uploadFileResponseStreamController.add(rustSignal);
    UploadFileResponse.latestRustSignal = rustSignal;
  },
  'UploadProgress': (Uint8List messageBytes, Uint8List binary) {
    final message = UploadProgress.bincodeDeserialize(messageBytes);
    final rustSignal = RustSignalPack(
      message,
      binary,
    );
    _uploadProgressStreamController.add(rustSignal);
    UploadProgress.latestRustSignal = rustSignal;
  },
  'UploadTextResponse': (Uint8List messageBytes, Uint8List binary) {
    final message = UploadTextResponse.bincodeDeserialize(messageBytes);
    final rustSignal = RustSignalPack(
      message,
      binary,
    );
    _uploadTextResponseStreamController.add(rustSignal);
    UploadTextResponse.latestRustSignal = rustSignal;
  },
};
