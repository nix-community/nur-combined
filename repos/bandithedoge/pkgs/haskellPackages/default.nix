{
  pkgs ? import <nixpkgs> {},
  sources ? ../../_sources/generated.nix,
}: let
  callHaskellPackage = pkg: let
    haskellNix = import sources.haskellNix.src {};
  in
    pkgs.callPackage pkg {
      inherit pkgs sources;
      haskellNix = (import haskellNix.sources.nixpkgs haskellNix.nixpkgsArgs).haskell-nix;
    };
in {
  taffybar = callHaskellPackage ./taffybar.nix;
  kmonad = callHaskellPackage ./kmonad.nix;
  xmonad-entryhelper = callHaskellPackage ./xmonad-entryhelper.nix;
}
