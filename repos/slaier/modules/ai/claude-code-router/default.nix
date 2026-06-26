{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.claude-code-router;

  configFile =
    if cfg.configFile != null then
      cfg.configFile
    else
      pkgs.writeText "claude-code-router-config.json" (builtins.toJSON cfg.settings);

in
{
  options.services.claude-code-router = {
    enable = mkEnableOption "Claude Code Router service";

    package = mkPackageOption pkgs "claude-code-router" { };

    settings = mkOption {
      type = types.attrs;
      default = { };
    };

    configFile = mkOption {
      type = types.nullOr (types.either types.path types.str);
      default = null;
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.claude-code-router = {
      description = "Claude Code Router Service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      environment = {
        HOME = "/var/lib/claude-code-router";
      };

      serviceConfig = {
        Type = "simple";
        ExecStart = "${lib.getExe cfg.package} start";
        Restart = "always";
        RestartSec = "5s";

        DynamicUser = true;
        StateDirectory = "claude-code-router";

        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        EnvironmentFile = mkIf (cfg.environmentFile != null) cfg.environmentFile;
      };

      preStart = ''
        mkdir -p /var/lib/claude-code-router/.claude-code-router
        ln -sf ${configFile} /var/lib/claude-code-router/.claude-code-router/config.json
      '';
    };
  };
}
