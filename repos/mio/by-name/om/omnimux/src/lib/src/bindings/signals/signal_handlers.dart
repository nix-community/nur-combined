part of 'signals.dart';

final assignRustSignal = <String, void Function(Uint8List, Uint8List)>{
  'SshHostsResult': (Uint8List messageBytes, Uint8List binary) {
    final message = SshHostsResult.bincodeDeserialize(messageBytes);
    final rustSignal = RustSignalPack(
      message,
      binary,
    );
    _sshHostsResultStreamController.add(rustSignal);
    SshHostsResult.latestRustSignal = rustSignal;
  },
  'TerminalExit': (Uint8List messageBytes, Uint8List binary) {
    final message = TerminalExit.bincodeDeserialize(messageBytes);
    final rustSignal = RustSignalPack(
      message,
      binary,
    );
    _terminalExitStreamController.add(rustSignal);
    TerminalExit.latestRustSignal = rustSignal;
  },
  'TerminalOutput': (Uint8List messageBytes, Uint8List binary) {
    final message = TerminalOutput.bincodeDeserialize(messageBytes);
    final rustSignal = RustSignalPack(
      message,
      binary,
    );
    _terminalOutputStreamController.add(rustSignal);
    TerminalOutput.latestRustSignal = rustSignal;
  },
};
