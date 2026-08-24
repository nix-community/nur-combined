{
  lib,
  buildGoApplication,
  source,
}:
import ./package.nix {inherit lib buildGoApplication;} {
  inherit source;
  modules = ./gomod2nix.toml;
  version = lib.removePrefix "v" source.version;
}
