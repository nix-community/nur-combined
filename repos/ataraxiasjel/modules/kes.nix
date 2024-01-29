{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.kes;
  format = pkgs.formats.yaml { };
  configFile = format.generate "config.yaml" cfg.settings;
  port = strings.toInt (lists.last (strings.splitString ":" cfg.settings.address));
in
{
  options.services.kes = {
    enable = mkEnableOption (mdDoc "Key Managament Server");
    package = mkOption {
      type = types.package;
      description = mdDoc "Which package to use for the kes instance.";
      default = pkgs.kes;
    };
    environmentFile = mkOption {
      type = with types; nullOr str;
      default = null;
      description = lib.mdDoc ''
        File in the format of an EnvironmentFile as described by systemd.exec(5).
      '';
    };
    settings = mkOption {
      type = format.type;
      default = {
        address = "0.0.0.0:7373";
      };
      example = literalExpression ''
        {
          address = "0.0.0.0:7373";
          cache = {
            expiry = {
              any = "5m0s";
              unused = "20s";
            };
          };
        }
      '';
      description = mdDoc ''
        KES Configuration.
        Refer to <https://github.com/minio/kes/blob/master/server-config.yaml>
        for details on supported values.
      '';
    };
  };
  config = mkIf cfg.enable {
    systemd.services.kes = {
      description = "KES";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      path = [ cfg.package ];
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        ExecStart = "${cfg.package}/bin/kes server --config ${configFile}";
        User = "kes";
        Group = "kes";
        AmbientCapabilities = [ "CAP_IPC_LOCK" ] ++ optionals (port < 1024) [ "CAP_NET_BIND_SERVICE" ];
        LimitNOFILE = 65536;
        ProtectProc = "invisible";
        SendSIGKILL = "no";
        TasksMax = "infinity";
        TimeoutStopSec = "infinity";
      } // optionalAttrs (cfg.environmentFile != null) { EnvironmentFile = cfg.environmentFile; };
    };

    users.groups.kes = { };
    users.users.kes = {
      description = "KES user";
      group = "kes";
      isSystemUser = true;
    };
  };
}
