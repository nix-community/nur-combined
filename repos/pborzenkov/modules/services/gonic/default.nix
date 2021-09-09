{ lib, pkgs, config, ... }:

let
  cfg = config.services.gonic;
in
{
  options.services.gonic = {
    enable = lib.mkEnableOption "gonic music streaming service";

    listen = {
      address = lib.mkOption {
        type = lib.types.str;
        default = "0.0.0.0";
        description = "Address to listen on";
      };
      port = lib.mkOption {
        type = lib.types.int;
        default = 4747;
        description = "Port to listen on";
      };
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "gonic";
      description = "User account under which gonic runs";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "gonic";
      description = "Group account under which gonic runs";
    };

    musicPath = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Path to music collection";
    };
    podcastPath = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Path to podcast collection";
    };

    scanInterval = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
      description = "Interval in minutes to check for new music";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.musicPath != "";
        message = "Music path must be provided";
      }
      {
        assertion = cfg.podcastPath != "";
        message = "Podcast path must be provided";
      }
    ];

    systemd.services.gonic = {
      description = "gonic music streaming service";

      wantedBy = [ "multi-user.target" ];

      path = [ pkgs.ffmpeg ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;

        StateDirectory = "gonic";
        ExecStartPre = let
          preStartScript = pkgs.writeScript "gonic-run-prestart" ''
            #!${pkgs.bash}/bin/bash

            if ! test -d "/var/lib/gonic/cache"; then
              install -d -m 0755 -o "${cfg.user}" -g "${cfg.group}" /var/lib/gonic/cache
            fi
          '';
        in
          "!${preStartScript}";

        ExecStart = ''
          ${pkgs.gonic}/bin/gonic \
          -music-path ${cfg.musicPath} \
          -podcast-path ${cfg.podcastPath} \
          -cache-path /var/lib/gonic/cache \
          -db-path /var/lib/gonic/gonic.db \
          -listen-addr ${cfg.listen.address}:${toString cfg.listen.port} \
          ${lib.optionalString (cfg.scanInterval != null) "-scan-interval ${toString cfg.scanInterval}"}
        '';
      };
    };

    users.users = lib.mkIf (cfg.user == "gonic") {
      gonic = {
        isSystemUser = true;
        group = cfg.group;
      };
    };

    users.groups = lib.mkIf (cfg.group == "gonic") {
      gonic = {};
    };
  };
}
