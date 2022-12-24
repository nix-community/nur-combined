{ ... }:

{
  # Ensure Iosevka is there
  imports = [
    ./fonts.nix
  ];

  home.file.".config/alacritty/alacritty.yml".source = ../../../misc/dotfiles/config/alacritty/config.yml;
}
