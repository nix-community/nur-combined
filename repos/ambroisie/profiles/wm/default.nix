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
      # Screenshot tool
      my.home.flameshot.enable = true;
      # Auto disk mounter
      my.home.udiskie.enable = true;
      # udiskie fails if it can't find this dbus service
      services.udisks2.enable = true;
    })
  ];
}
