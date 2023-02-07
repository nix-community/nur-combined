{ config, pkgs, lib, ... }: {
  imports = [
    ../../modules/fonts
    ../../modules/lorri
    ../../modules/nix
    ../../modules/time
    ../../modules/timesyncd
    ../../modules/zsh
  ];
}
