{
  lib,
  buildGoApplication,
  libffi,
  source,
  stdenv,
}:
import ../manboster/package.nix {inherit lib buildGoApplication libffi stdenv;} {
  inherit source;
  modules = ./gomod2nix.toml;
  version = lib.removePrefix "v" source.version;
}
