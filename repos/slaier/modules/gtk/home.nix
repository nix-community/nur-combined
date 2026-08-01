{ pkgs, ... }:
{
  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.capitaine-cursors;
      name = "capitaine-cursors";
    };
    theme = {
      package = pkgs.adw-gtk3;
      name = "adw-gtk3-dark";
    };
  };
}
