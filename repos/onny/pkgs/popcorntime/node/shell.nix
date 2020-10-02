{ pkgs ? import ../../pkgs.nix }:
with import pkgs {};
with callPackage ../src.nix {};
stdenvNoCC.mkDerivation {
  name = "${name}-node2nix-env";
  inherit src;
  nativeBuildInputs = [
    git nodePackages.node2nix
  ];
}
