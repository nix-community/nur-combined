{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types;
  cfg = config.services.hentai-at-home;
in
{
  options = {
    services.hentai-at-home = {
      enable = lib.mkEnableOption "hentai-at-home";

      package = lib.mkPackageOption pkgs "hentai-at-home" { };

      user = lib.mkOption {
        type = lib.types.str;
        default = "hentai-at-home";
        description = "hentai-at-home user name.";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "hentai-at-home";
        description = "hentai-at-home group name.";
      };

      baseDirectory = lib.mkOption {
        type = types.path;
        default = "/var/lib/hentai-at-home";
      };

      extraFlags = lib.mkOption {
        type = types.listOf types.str;
        default = [ ];
      };

      port = lib.mkOption {
        type = types.port;
        default = 1024;
      };

      openFirewall = lib.mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.hentai-at-home = lib.optionalAttrs (cfg.user == "hentai-at-home") {
      description = "hentai-at-home user";
      isSystemUser = true;
      inherit (cfg) group;
    };
    users.groups.hentai-at-home = lib.optionalAttrs (cfg.group == "hentai-at-home") { };
    networking.firewall.allowedTCPPorts = lib.optional cfg.openFirewall cfg.port;

    systemd.services.hentai-at-home = {
      serviceConfig = {
        ExecStart = lib.concatStringsSep " " (
          [
            (lib.getExe cfg.package)
            "--port=${toString cfg.port}"
            "--cache-dir=${cfg.baseDirectory}/cache"
            "--data-dir=${cfg.baseDirectory}/data"
            "--download-dir=${cfg.baseDirectory}/download"
            "--log-dir=${cfg.baseDirectory}/log"
            "--temp-dir=${cfg.baseDirectory}/temp"
          ]
          ++ cfg.extraFlags
        );
        Type = "simple";
        Restart = "always";
        StateDirectory = "hentai-at-home";

        User = cfg.user;
        Group = cfg.group;

        # Hardening
        PrivateUsers = cfg.port >= 1024; # incompatible with CAP_NET_BIND_SERVICE
        CapabilityBoundingSet = lib.optionalString (cfg.port < 1024) "CAP_NET_BIND_SERVICE";
        AmbientCapabilities = lib.optionalString (cfg.port < 1024) "CAP_NET_BIND_SERVICE";
        NoNewPrivileges = true;
        RemoveIPC = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
      };
      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ moraxyc ];
}
