{ config, pkgs, lib, flake, ... }: {
  imports = [
    ../../modules/agenix
    ../../modules/clamav
    ../../modules/docker
    ../../modules/fonts
    ../../modules/gnome
    ../../modules/gnupg
    ../../modules/lorri
    ../../modules/networking
    ../../modules/nix
    ../../modules/openssh
    ../../modules/pipewire
    ../../modules/steam
    ../../modules/tailscale
    ../../modules/time
    ../../modules/timesyncd
    ../../modules/udev
    ../../modules/zsh
  ];
}
