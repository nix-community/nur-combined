{ config, pkgs, ... }:

{

  # Display
  # https://discourse.nixos.org/t/brightness-control-of-external-monitors-with-ddcci-backlight/8639
  boot.extraModulePackages = [ config.boot.kernelPackages.ddcci-driver ];
  hardware.i2c.enable = true;
  boot.kernelModules = [ "ddcci_backlight" ];
  environment.systemPackages = [ pkgs.brightnessctl ];

  # These two need a fix:
  # From here: https://github.com/NixOS/nixpkgs/issues/297312#issuecomment-2102378983
  # That issue is closed but not fixed.
  # run to check: $ brightnessctl -m --class=backlight --list info
  # to find:
  # $ S: ddcutil ; $ ddcutil detect
  # boot.postBootCommands =
  #   # does not work in this place
  #   ''
  #     echo ddcci 0x37 > /sys/bus/i2c/devices/i2c-4/new_device
  #     echo ddcci 0x37 > /sys/bus/i2c/devices/i2c-12/new_device
  #   '';
}
