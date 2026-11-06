{
  uutils-diffutils,
  gnupatch,
  lib,
  runCommandLocal,
  stdenv,
}:

uutils-diffutils.overrideAttrs (
  old:
  lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    # The test suite validates generated patches by applying them with GNU
    # patch. On darwin it looks the binary up as `gpatch` (the Homebrew name),
    # while nixpkgs' gnupatch only installs `patch`, so every permutation test
    # fails with "No such file or directory".
    nativeCheckInputs = (old.nativeCheckInputs or [ ]) ++ [
      (runCommandLocal "gpatch-${gnupatch.version}" { } ''
        mkdir -p $out/bin
        ln -s ${lib.getExe gnupatch} $out/bin/gpatch
      '')
    ];
  }
)
