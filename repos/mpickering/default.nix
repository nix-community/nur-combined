{ pkgs }:
{
  overlays = { haskell-plugins = import ./haskell-plugins; };

  ghc-head-from = pkgs.callPackage ./ghc-artefact-nix/ghc-head-from.nix {};

  ghc = pkgs.callPackage ./old-ghc-nix {};
}
