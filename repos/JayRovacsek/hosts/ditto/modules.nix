{ config, pkgs, lib, ... }: {
  imports = [
    ../../modules/agenix
    ../../modules/clamav
    ../../modules/gnupg
    ../../modules/lorri
    ../../modules/nix
    ../../modules/openssh
    ../../modules/time
    ../../modules/timesyncd
    ../../modules/zsh
  ];
}
