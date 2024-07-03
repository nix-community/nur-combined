{ callPackage, lib }:

lib.mapAttrs' (filename: _filetype: {
  name = lib.removeSuffix ".nix" filename;
  value = (callPackage (./. + "/${filename}") { });
}) (builtins.readDir ./.)
