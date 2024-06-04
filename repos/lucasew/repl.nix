let
  default = import ./default.nix;
in
default
// {
  pkgs = default.legacyPackages;
  lib = default.legacyPackages.lib;
  inherit (default)
    homeConfigurations
    deploy
    nixosConfigurations
    release
    nixOnDroidConfigurations
    ;
}
