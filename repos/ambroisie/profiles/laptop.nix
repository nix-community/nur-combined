{ config, lib, ... }:
let
  cfg = config.my.profiles.laptop;
in
{
  options.my.profiles.laptop = with lib; {
    enable = mkEnableOption "laptop profile";
  };

  config = lib.mkIf cfg.enable {
    # Enable touchpad support
    services.xserver.libinput.enable = true;
  };
}
