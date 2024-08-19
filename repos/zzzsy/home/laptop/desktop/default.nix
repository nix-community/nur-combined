{ pkgs, ... }:
{
  imports = [
    ./gnome/dconf.nix
    # ./hyprland
    # ./cosmic.nix
  ];

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.papirus-icon-theme.override { color = "adwaita"; };
      name = "Papirus";
    };
  };

  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    gtk.enable = true;
    x11.enable = true;
    size = 24;
  };

  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style.name = "adwaita";
  };

  home.packages = with pkgs; [
    xdg-user-dirs
    xdg-utils
  ];
}
