{
  lib,
  stdenv,
  stdenvAdapters,
  clangStdenv,
  callPackage,
}:
let
  adapters = lib.optionals (!stdenv.targetPlatform.isDarwin) [
    stdenvAdapters.useWildLinker
  ];
  customStdenv = lib.pipe clangStdenv adapters;
in
callPackage ./package.nix { stdenv = customStdenv; }
