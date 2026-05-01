{ config, lib, ... }:
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

    # X configuration
    my.home.x.enable = true;
  };
}
