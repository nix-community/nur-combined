{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.lnshot;
  lnshot = pkgs.callPackage ../pkgs/lnshot {};
in {
  options.services.lnshot = { enable = mkEnableOption "lnshot service"; };

  config = mkIf cfg.enable {
    home.packages = [ lnshot ];

    systemd.user.services.lnshot = {
      Unit = {
        Description = "Steam Screenshot Symlinking Service";
      };
      Service = {
        ExecStart = "${lnshot}/bin/lnshot daemon";
        Restart = "always";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
