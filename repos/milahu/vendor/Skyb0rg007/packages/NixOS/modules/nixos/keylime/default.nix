{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.keylime;
in
{
  options.services.keylime = {
    enable = lib.mkEnableOption "keylime";
    package = lib.mkPackageOption pkgs "keylime" { };
  };

  config = lib.mkIf cfg.enable {
    users.users.keylime = {
      isSystemUser = "keylime";
      group = "keylime";
    };
    users.groups.keylime = { };

    systemd.services.keylime_registrar = {
      description = "The Keylime registrar service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${lib.getExe' cfg.package "keylime_registrar"}";
        User = "keylime";
        Group = "keylime";
        TimoutSec = "60s";
        Restart = "on-failure";
        RestartSec = "120s";
        StateDirectory = "keylime";
        RuntimeDirectory = "keylime";
        ConfigurationDirectory = "keylime";
      };
    };

    systemd.services.keylime_verifier = {
      description = "The Keylime verifier";
      after = [ "network.target" ];
      before = [ "keylime_registrar.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${lib.getExe' cfg.package "keylime_verifier"}";
        User = "keylime";
        Group = "keylime";
        TimoutSec = "60s";
        Restart = "on-failure";
        RestartSec = "120s";
        StateDirectory = "keylime";
        RuntimeDirectory = "keylime";
        ConfigurationDirectory = "keylime";
      };
    };

    systemd.tmpfiles.settings."10-keylime" = {
      "/etc/keylime" = {
        d = {
          user = "keylime";
          group = "keylime";
          mode = "0500";
        };
      };
      "/etc/keylime/ca.conf.d" = {
        d = {
          user = "keylime";
          group = "keylime";
          mode = "0500";
        };
      };
      "/etc/keylime/logging.conf.d" = {
        d = {
          user = "keylime";
          group = "keylime";
          mode = "0500";
        };
      };
      "/etc/keylime/verifier.conf.d" = {
        d = {
          user = "keylime";
          group = "keylime";
          mode = "0500";
        };
      };
      "/etc/keylime/registrar.conf.d" = {
        d = {
          user = "keylime";
          group = "keylime";
          mode = "0500";
        };
      };
      "/etc/keylime/tenant.conf.d" = {
        d = {
          user = "keylime";
          group = "keylime";
          mode = "0500";
        };
      };
      "/etc/keylime/agent.conf.d" = {
        d = {
          user = "keylime";
          group = "keylime";
          mode = "0500";
        };
      };
    };
  };
}
