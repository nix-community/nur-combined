{ pkgs }:
{
  # Add Haskell packages here

  discord-haskell = pkgs.haskellPackages.callPackage ./discord-haskell.nix { };
}

