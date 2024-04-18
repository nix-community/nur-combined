let
  default = import ./default.nix;
in
default
// {
  pkgs = default.legacyPackages;
  lib = default.legacyPackages.lib;
  inherit (default.packages)
    homeConfigurations
    deploy
    nixosConfigurations
    release
    nixOnDroidConfigurations
    ;
}
