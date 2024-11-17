{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.brightnessctl;
in
{
  sane.programs.brightnessctl = {
    sandbox.extraPaths = [
      "/sys/class/backlight"
      "/sys/class/leds"
      "/sys/devices"
    ];
    # sandbox.whitelistDbus = [ "system" ];  #< only necessary if not granting udev perms
  };

  services.udev.extraRules = let
    chmod = lib.getExe' pkgs.coreutils "chmod";
    chown = lib.getExe' pkgs.coreutils "chown";
  in lib.mkIf cfg.enabled ''
    # make backlight controllable by members of `video`
    SUBSYSTEM=="backlight", RUN+="${chown} :video $sys$devpath/brightness", RUN+="${chmod} g+w $sys$devpath/brightness"
  '';
}
