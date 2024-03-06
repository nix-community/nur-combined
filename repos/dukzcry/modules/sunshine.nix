{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.sunshine;
in {
  options.programs.sunshine = {
    enable = mkEnableOption "Sunshine headless server";
    games = mkOption {
      type = types.listOf types.package;
      default = [];
    };
  };

  config = mkMerge [
   (mkIf cfg.enable {
      hardware.uinput.enable = true;
      environment.systemPackages = cfg.games;
      services.udev.extraRules = ''
        KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", TAG+="uaccess"
      '';
      security.wrappers.sunshine = {
        owner = "root";
        group = "root";
        capabilities = "cap_sys_admin+p";
        source = "${pkgs.nur.repos.dukzcry.sunshine}/bin/sunshine";
      };
      systemd.user.services.sunshine = {
        description = "Sunshine headless server";
        wantedBy = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        startLimitIntervalSec = 500;
        startLimitBurst = 5;
        serviceConfig = {
          ExecStart = pkgs.writeShellScript "sunshine" ''
            . /etc/set-environment
            ${config.security.wrapperDir}/sunshine
          '';
          RestartSec = 5;
          Restart = "on-failure";
        };
      };
   })
  ];
}
