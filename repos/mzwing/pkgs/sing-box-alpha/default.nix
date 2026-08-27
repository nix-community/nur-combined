{
  callPackage,
  lib,
  source,
}:
callPackage ../sing-box-rc/package.nix {
  inherit source;
  modules = ./gomod2nix.toml;
  version = lib.removePrefix "v" source.version;
}
