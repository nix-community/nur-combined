{
  callPackage,
  lib,
  source,
}:
callPackage ./package.nix {
  inherit source;
  modules = ./gomod2nix.toml;
  version = lib.removePrefix "v" source.version;
}
