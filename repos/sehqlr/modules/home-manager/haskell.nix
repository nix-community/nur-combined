{ config, lib, pkgs, ... }: {
  home.packages =
    [ pkgs.cabal-install pkgs.haskell-language-server pkgs.stack ];
}
