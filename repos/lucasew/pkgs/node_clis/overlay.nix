self: super:
let
  npmPackages = import ./package_data/default.nix { inherit (super) pkgs; };
in {
  nodePackages = super.nodePackages // npmPackages // {
  };
}
