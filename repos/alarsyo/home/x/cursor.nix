{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.my.home.x.cursor;
in {
  options.my.home.x.cursor.enable = (mkEnableOption "X cursor") // {default = config.my.home.x.enable;};

  config = mkIf cfg.enable {
    home.pointerCursor = {
      #package = pkgs.capitaine-cursors;
      #name = "capitaine-cursors";
      #package = pkgs.catppuccin-cursors.frappeDark;
      #name = "catppuccin-frappe-dark-cursors";
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      # https://unix.stackexchange.com/a/743543
      size = 24;
      x11.enable = true;
      gtk.enable = true;
    };
  };
}
