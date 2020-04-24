{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.openarc;

  defaultSock = "local:/run/openarc/openarc.sock";

  args = [ "-f"
           "-p" cfg.socket
         ] ++ optionals (cfg.configFile != null) [ "-c" cfg.configFile ];

in {

  ###### interface

  options = {

    services.openarc = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable the OpenARC sender authentication system.";
      };

      socket = mkOption {
        type = types.str;
        default = defaultSock;
        description = "Socket which is used for communication with OpenARC.";
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
        description = "Additional OpenARC configuration.";
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    users.users = optionalAttrs (cfg.user == "openarc") (singleton
      { name = "openarc";
        group = cfg.group;
        uid = config.ids.uids.openarc;
      });

    users.groups = optionalAttrs (cfg.group == "openarc") (singleton
      { name = "openarc";
        gid = config.ids.gids.openarc;
      });

    environment.systemPackages = [ pkgs.openarc ];

    systemd.services.openarc = {
      description = "OpenARC daemon";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.openarc}/bin/openarc ${escapeShellArgs args}";
        User = cfg.user;
        Group = cfg.group;
        RuntimeDirectory = optional (cfg.socket == defaultSock) "openarc";
        PermissionsStartOnly = true;
      };
    };

  };
}
