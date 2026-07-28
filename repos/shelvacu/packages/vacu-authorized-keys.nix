{
  vacu-keys-src,
  lib,
  writeText,
}:
lib.pipe vacu-keys-src [
  import
  (lib.mapAttrsToList (name: sshPubKey: "${sshPubKey} ${name}"))
  lib.concatLines
  (writeText "vacu-authorized-keys")
]
