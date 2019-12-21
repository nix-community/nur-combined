{ pkgs }:
{
  # Add Haskell packages here
  arion-compose = pkgs.haskellPackages.callPackage ./arion-compose.nix { };
}
