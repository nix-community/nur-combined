{ pkgs, ... }:

{
  # Ensure Iosevka is there
  imports = [
    ./fonts.nix
  ];
  
  programs.kitty = {
    enable = true;
    font = {
      package = iosevka-nerdfonts;
      name = "Iosevka Term";
    };
  };
}
