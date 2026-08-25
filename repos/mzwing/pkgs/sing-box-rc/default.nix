{
  lib,
  buildGoApplication,
  buildPackages,
  coreutils,
  installShellFiles,
  source,
}:
import ./package.nix {inherit lib buildGoApplication buildPackages coreutils installShellFiles;} {
  inherit source;
  modules = ./gomod2nix.toml;
  version = lib.removePrefix "v" source.version;
}
