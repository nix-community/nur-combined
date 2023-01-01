{ inputs, ... }:

let
  inherit (inputs) dotfiles;

in {
  # Ensure Iosevka is there
  imports = [
    ./fonts.nix
  ];

  home.file.".config/alacritty/alacritty.yml".source = "${dotfiles}/config/alacritty/config.yml";
}
