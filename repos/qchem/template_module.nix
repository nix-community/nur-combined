{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.XXX;
in
{
  ###### interface

  options = {
    services.XXX = {
     enable = mkEnableOption "slurm control daemon";
    };
  };

  ###### implementation

  config = {
    systemd.services.XXX {
      path = with pkgs; [ coreutils ];
      
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      requires = [ "" ];

      serviceConfig = {
        Type = "forking";
        ExecStart = "${XXX}/bin/XXX";
        PIDFile = "/run/XXX.pid";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
      };
    };
  };
}

