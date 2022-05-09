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
      package = pkgs.capitaine-cursors;
      name = "capitaine-cursors";
      # available sizes for capitaine-cursors are:
      # 24, 30, 36, 48, 60, 72
      size = 30;
      x11.enable = true;
    };
  };
}
