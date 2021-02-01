{ lib, pkgs, config, ... }:
let
  cfg = config.services.strongdm;
in {
  options.services.strongdm = {
    enable = lib.mkEnableOption "strongdm";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.myPackages.strongdm];
    systemd.user.services.strongdm = {
      Unit = {
        Description="Strongdm";
        ConditionFileIsExecutable = "${pkgs.myPackages.strongdm}/bin/sdm";
        Requires = "default.target";
        After = "default.target";
      };
      Service = {
        ExecStart = "${pkgs.myPackages.strongdm}/bin/sdm \"listen\"";
        Restart="always";
        RestartSec="3";
      };
      Install = {
        WantedBy=["default.target"];
      };
    };
  };
}
