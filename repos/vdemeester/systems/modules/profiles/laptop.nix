{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.laptop;
in
{
  options = {
    profiles.laptop = {
      enable = mkOption {
        default = false;
        description = "Enable laptop profile";
        type = types.bool;
      };
    };
  };
  config = mkIf cfg.enable {
    boot.kernel.sysctl = {
      "vm.swappiness" = 10;
      "vm.dirty_ratio" = 25;
      "vm.dirty_background_ratio" = 10;
      "vm.dirty_writeback_centisecs" = 5000;
      "vm.dirty_expire_centisecs" = 5000;
    };
    environment.systemPackages = with pkgs; [
      lm_sensors
      powertop
      acpi
    ];
    profiles.desktop.enable = true;
    systemd.services.nix-gc.unitConfig.ConditionACPower = true;
  };
}
