{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.bs-munge;
  preStart = pkgs.writeScript "munge-pre-start" ''
    #!${pkgs.runtimeShell}
    mkdir -p /etc/munge
    echo mungeverryweakkeybuteasytointegratoinatest >  ${cfg.password}
    chmod 0400 ${cfg.password}
    chown munge:munge ${cfg.password}
  '';  
in

{

  ###### interface

  options = {

    services.bs-munge = {
      enable = mkEnableOption "bs-munge service";

      password = mkOption {
        default = "/etc/munge/munge.key";
        type = types.path;
        description = ''
          The path to a daemon's secret key.
        '';
      };

    };

  };

  ###### implementation

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkgs.munge ];

    users.users.munge = {
      description   = "Munge daemon user";
      isSystemUser  = true;
      group         = "munge";
    };

    users.groups.munge = {};

    systemd.services.bs-munged = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      path = [ pkgs.munge pkgs.coreutils ];

      serviceConfig = {
        ExecStartPre = "+${preStart}";
        ExecStart = "${pkgs.munge}/bin/munged --syslog --key-file ${cfg.password}";
        PIDFile = "/run/munge/munged.pid";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        User = "munge";
        Group = "munge";
        StateDirectory = "munge";
        StateDirectoryMode = "0711";
        RuntimeDirectory = "munge";
      };
    };

  };

}
