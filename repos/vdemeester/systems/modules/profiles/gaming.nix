{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.gaming;
in
{
  options = {
    profiles.gaming = {
      enable = mkOption {
        default = false;
        description = "Enable gaming profile";
        type = types.bool;
      };
    };
  };
  config = mkIf cfg.enable {
    hardware = {
      opengl = {
        driSupport32Bit = true;
      };
    };
    services.udev.extraRules = ''
      # Steam controller
      SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0666"
      KERNEL=="uinput", MODE="0660", GROUP="users", OPTIONS+="static_node=uinput"
    '';
    environment.systemPackages = with pkgs; [ steam ];
  };
}
