{
  lib,
  stdenvAdapters,
  clangStdenv,
  callPackage,
}:
let
  adapters = [
    stdenvAdapters.useMoldLinker
  ];
  customStdenv = lib.pipe clangStdenv adapters;
in
callPackage ./package.nix { stdenv = customStdenv; }
