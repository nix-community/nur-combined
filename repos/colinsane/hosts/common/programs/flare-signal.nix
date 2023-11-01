# Flare is a 3rd-party GTK4 Signal app.
# UI is effectively a clone of Fractal.
#
# compatibility:
# - desko: works fine. pairs, and exchanges contact list (but not message history) with the paired device. exchanges future messages fine.
# - moby (cross compiled flare-signal-nixified): nope. it pairs, but can only *receive* messages and never *send* them.
#   - even `rsync`ing the data and keyrings from desko -> moby, still fails in that same manner.
#   - console shows error messages. quite possibly an endianness mismatch somewhere
# - moby (partially-emulated flare-signal): works! pairs and can send/receive messages, same as desko.
#
# error signatures (to reset, run `sane-wipe-fractal`):
# - upon sending a message, the other side receives it, but Signal desktop gets "A message from Colin could not be delivered" and the local CLI shows:
#   ```
#   ERROR libsignal_service::websocket] SignalWebSocket: Websocket error: SignalWebSocket: end of application request stream; socket closing
#   ERROR presage::manager] Error opening envelope: ProtobufDecodeError(DecodeError { description: "invalid tag value: 0", stack: [("Content", "data_message")] }), message will be skipped!
#   ERROR presage::manager] Error opening envelope: ProtobufDecodeError(DecodeError { description: "invalid tag value: 0", stack: [("Content", "data_message")] }), message will be skipped!
#   ```
# - this occurs on moby, desko, `flare-signal` and `flare-signal-nixified`
# - the Websocket error seems to be unrelated, occurs during normal/good operation
# - related issues: <https://github.com/whisperfish/presage/issues/152>
# error when sending from Flare to other Flare device:
# - ```
#   ERROR libsignal_protocol::session_cipher] Message from <UUID>.3 failed to decrypt; sender ratchet public key <key> message counter 1
#       No current session
#   ERROR presage::manager] Error opening envelope: SignalProtocolError(InvalidKyberPreKeyId), message will be skipped!
#   ```
# - but signal iOS will still read it.
#
# well, seems to have unpredictable errors particularly when being used on multiple devices.
# desktop _seems_ more reliable than on mobile, but not confident.

{ pkgs, ... }:
{
  sane.programs.flare-signal = {
    package = pkgs.flare-signal-nixified;
    # package = pkgs.flare-signal;
    persist.private = [
      # everything: conf, state, files, all opaque
      ".local/share/flare"
      # also persists a secret in ~/.local/share/keyrings. reset with:
      # - `secret-tool search --all --unlock 'xdg:schema' 'de.schmidhuberj.Flare'`
      # - `secret-tool clear 'xdg:schema' 'de.schmidhuberj.Flare'`
      # and it persists some dconf settings (e.g. device name). reset with:
      # - `dconf reset -f /de/schmidhuberj/Flare/`.
    ];
  };
}
