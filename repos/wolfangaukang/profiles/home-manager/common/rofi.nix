{ ... }:
let
  black = "#0d0d0d";
  yellow_strong = "#eed12b";
  orange = "#d34324";
  yellow = "#f2dc5d";
in {
  # Ensure Iosevka is there
  imports = [
    ./fonts.nix
  ];

  programs.rofi = {
    enable = true;
    font = "Iosevka Term 13";
    colors = {
      window = {
        background = black;
        border = black;
        separator = yellow_strong;
      };
      rows = {
        normal = {
          background = black;
          foreground = yellow;
          backgroundAlt = black;
          highlight = {
            background = orange;
            foreground = yellow_strong;
          };
        };
      };
    };
  };
}
