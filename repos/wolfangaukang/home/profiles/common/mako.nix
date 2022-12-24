{ ... }:

{
  # Ensure Iosevka is there
  imports = [
    ./fonts.nix
  ];

  programs.mako = {
    enable = true;
    font = "Iosevka Term 10";
    backgroundColor = "#0d0d0d";
    borderColor = "#0d0d0d";
    textColor = "#d34324";
  };
}
