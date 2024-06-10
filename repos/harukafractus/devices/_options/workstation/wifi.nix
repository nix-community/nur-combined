{ lib, pkgs, config, ... }:
with lib;                      
let
  cfg = config.workstation.wifi;
in {
  options.workstation.wifi = {
    provider = mkOption {
      type    = types.enum [ "wpa_supplicant" "iwd" ];
      default = "wpa_supplicant";
    };
  };

  config = {
    # Enable NetworkManager & wpa
    networking = if cfg.provider == "wpa_supplicant" then {
      networkmanager.enable = true;
    } else {
      networkmanager.wifi.backend = "iwd";
      # Disable wpa_supplicant to avoid conflict
      wireless.enable = true;
      dhcpcd.enable = false;

      # Enable iwctl
      wireless.iwd = {
        enable = true;
        settings = {
          General = {
            EnableNetworkConfiguration = true;
          };
          Settings = {
            AlwaysRandomizeAddress = true; 
          };
          Network = {
            EnableIPv6 = false;
          };
        };
      };
    };
  };
}
