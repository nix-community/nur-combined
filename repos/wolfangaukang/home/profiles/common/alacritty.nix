{ inputs, ... }:

let
  inherit (inputs) self dotfiles;

in {
  # Ensure Iosevka is there
  imports = [
    "${self}/home/profiles/configurations/fonts.nix"
  ];

  home.file.".config/alacritty/alacritty.yml".source = "${dotfiles}/config/alacritty/config.yml";
}
