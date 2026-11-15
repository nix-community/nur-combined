{
  lib,
  writers,
  nixVersions,
  nix-update,
  bash,
  stdenv,
}:
writers.writePython3Bin "test-nix-hash" {
  flakeIgnore = [ "E501" ];
  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      nixVersions.latest
      nix-update
    ])
    "--set"
    "NIX_HASH_TEST_BASH"
    "${bash}"
    "--set"
    "NIX_HASH_TEST_SYSTEM"
    stdenv.hostPlatform.system
    "--set"
    "NIX_HASH_TEST_SCRIPT"
    "${./nix_hash.py}"
  ];
} ./test_nix_hash.py
