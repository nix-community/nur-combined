{ lib, pkgs, config, ... }:
with lib;                      
let
  cfg = config.workstation.airprint;
in {
  options.workstation.airprint = {
    enable = mkEnableOption "Printer Support: Enable CUPS and Avahi";
  };

  config = mkIf cfg.enable {
    # Enable CUPS
    services.printing.enable = true;

    # Enable Avahi for printer discovery
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
