{ config, lib, pkgs, ... }:
let
  cfg = config.my.profiles.x;
in
{
  options.my.profiles.x = with lib; {
    enable = mkEnableOption "X profile";
  };

  config = lib.mkIf cfg.enable {
    # Enable the X11 windowing system.
    services.xserver.enable = true;
    # Nice wallpaper
    services.xserver.displayManager.lightdm.background =
      let
        wallpapers = "${pkgs.plasma5Packages.plasma-workspace-wallpapers}/share/wallpapers";
      in
      "${wallpapers}/summer_1am/contents/images/2560x1600.jpg";

    # X configuration
    my.home.x.enable = true;
  };
}
