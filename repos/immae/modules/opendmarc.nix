{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.opendmarc;

  defaultSock = "local:/run/opendmarc/opendmarc.sock";

  args = [ "-f" "-l"
           "-p" cfg.socket
         ] ++ optionals (cfg.configFile != null) [ "-c" cfg.configFile ];

in {

  ###### interface

  options = {

    services.opendmarc = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable the OpenDMARC sender authentication system.";
      };

      socket = mkOption {
        type = types.str;
        default = defaultSock;
        description = "Socket which is used for communication with OpenDMARC.";
      };

      user = mkOption {
        type = types.str;
        default = "opendmarc";
        description = "User for the daemon.";
      };

      group = mkOption {
        type = types.str;
        default = "opendmarc";
        description = "Group for the daemon.";
      };

      configFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "Additional OpenDMARC configuration.";
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    users.users = optionalAttrs (cfg.user == "opendmarc") {
      opendmarc = {
        group = cfg.group;
        uid = config.ids.uids.opendmarc;
      };
    };

    users.groups = optionalAttrs (cfg.group == "opendmarc") {
      opendmarc = {
        gid = config.ids.gids.opendmarc;
      };
    };

    environment.systemPackages = [ pkgs.opendmarc ];

    systemd.services.opendmarc = {
      description = "OpenDMARC daemon";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.opendmarc}/bin/opendmarc ${escapeShellArgs args}";
        User = cfg.user;
        Group = cfg.group;
        RuntimeDirectory = optional (cfg.socket == defaultSock) "opendmarc";
        PermissionsStartOnly = true;
      };
    };

  };
}
