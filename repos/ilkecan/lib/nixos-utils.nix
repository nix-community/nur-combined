{
  lib,
  nixpkgs,
}:

# Only the functions that use neither the NixOS configuration nor the package
# set are usable, such as `escapeSystemdExecArgs`.
import "${toString nixpkgs}/nixos/lib/utils.nix" {
  inherit lib;
  config = throw "nixosUtils: the NixOS configuration is unavailable";
  pkgs = throw "nixosUtils: the package set is unavailable";
}
