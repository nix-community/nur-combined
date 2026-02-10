{
  lib,
  stdenv,
  clangStdenv,
  stdenvAdapters,
  callPackage,
  asmc-linux,
  enableRar ? false,
}:
let
  adapters = lib.optionals (stdenv.targetPlatform.isLinux) [
    stdenvAdapters.useMoldLinker
  ];
  customStdenv = lib.pipe clangStdenv adapters;
in
callPackage ./package.nix {
  stdenv = customStdenv;
  inherit asmc-linux enableRar;
}
