{
  callPackage,
  lib,
  source,
}:
callPackage ../manboster/package.nix {
  inherit source;
  modules = ./gomod2nix.toml;
  version = lib.removePrefix "v" source.version;
}
