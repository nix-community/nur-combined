{
  perSystem = {pkgs, ...}: let
    inherit (pkgs) lib;
    legacy = import ../default.nix {inherit pkgs;};
    packages = lib.filterAttrs (_: lib.isDerivation) legacy;
  in {
    legacyPackages = legacy;
    inherit packages;
  };
}
