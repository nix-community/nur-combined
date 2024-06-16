{ lib, pkgs, config, ... }:
with lib;                      
let
  cfg = config.workstation.battery;
in {
  options.workstation.battery = {
    enable = mkEnableOption "Enable battery optimization";
  };

  config = mkIf cfg.enable {
    # Avoid Overheating
    services.thermald.enable = pkgs.system == "x86_64-linux";

    powerManagement = {
      enable = true;
      powertop.enable = true;
    };

    services.auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          governor = "powersave";
          turbo = "never";
        };
        charger = {
          governor = "performance";
          turbo = "auto";
        };
      };
    };
  };
}