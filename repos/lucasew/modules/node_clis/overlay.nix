self: super:
let
  npmPackages = import ./package_data/default.nix {pkgs = super.pkgs;};
in {
  nodePackages = super.nodePackages // npmPackages // {
    "a22120" = super.callPackage ./package_22120.nix {};
  };
}
