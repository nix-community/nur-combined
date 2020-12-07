{ config, lib, pkgs, ... }: {
  home.packages =
    [ pkgs.cabal-install pkgs.stack ];
}
