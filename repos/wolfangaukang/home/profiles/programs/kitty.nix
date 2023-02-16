{ inputs, ... }:

let
  inherit (inputs) self;

in {
  # Ensure Iosevka is there
  imports = [
    "${self}/home/profiles/configurations/fonts.nix"
  ];
  
  programs.kitty = {
    enable = true;
    font = {
      package = iosevka-nerdfonts;
      name = "Iosevka Term";
    };
  };
}
