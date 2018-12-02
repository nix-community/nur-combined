{ pkgs }:
{
  # Add Haskell packages here

  discord-haskell = pkgs.haskellPackages.callPackage ./discord-haskell.nix { };
  nixfmt = pkgs.haskellPackages.callPackage ./nixfmt.nix { };
}

