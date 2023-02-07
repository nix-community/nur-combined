{ config, pkgs, ... }: {
  imports = [
    ../../modules/docker-darwin
    ../../modules/dockutil
    ../../modules/darwin-settings
    ../../modules/documentation
    ../../modules/fonts
    ../../modules/gnupg
    ../../modules/lorri
    ../../modules/networking
    ../../modules/nix
    ../../modules/time
    ../../modules/yabai
    ../../modules/zsh
  ];
}
