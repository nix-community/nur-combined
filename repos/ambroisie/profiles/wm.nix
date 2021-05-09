{ config, lib, ... }:
let
  cfg = config.my.profiles.wm;
in
{
  options.my.profiles.wm = with lib; {
    windowManager = mkOption {
      type = with types; nullOr (enum [ "i3" ]);
      default = null;
      example = "i3";
      description = "Which window manager to use";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.windowManager == "i3") {
      # Enable i3
      services.xserver.windowManager.i3.enable = true;
      # i3 settings
      my.home.wm.windowManager = "i3";
    })
  ];
}
