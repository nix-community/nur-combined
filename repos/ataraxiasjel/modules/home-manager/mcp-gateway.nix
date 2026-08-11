{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.mcp-gateway;
  stateDir = if cfg.stateDir != null then cfg.stateDir else "${config.xdg.stateHome}/mcp-gateway";
in
{
  imports = [ ../common/mcp-gateway.nix ];

  config = mkIf cfg.enable {
    systemd.user.services.mcp-gateway = {
      Unit = {
        Description = "MCP Gateway";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
      Service = {
        ExecStart = concatStringsSep " " (
          [
            "${getExe cfg.package}"
            "--config"
            cfg.configFile
          ]
          ++ cfg.extraArguments
        );
        Restart = "on-failure";
        RestartSec = "5s";
        Path = [
          pkgs.nodejs
          pkgs.bash
        ]
        ++ cfg.extraPackages;
        Environment = [
          "MCP_GATEWAY_LOG_LEVEL=${cfg.logLevel}"
        ]
        ++ optional (cfg.logFormat != null) "MCP_GATEWAY_LOG_FORMAT=${cfg.logFormat}"
        ++ (mapAttrsToList (name: value: "${name}=${value}") cfg.extraEnvironment);
        WorkingDirectory = stateDir;
        MemoryMax = cfg.memoryMax;
        LimitNOFILE = 65536;
      }
      // optionalAttrs (cfg.environmentFile != null) { EnvironmentFile = cfg.environmentFile; };
    };

    systemd.user.tmpfiles.rules = [ "d ${stateDir} 0700 - - -" ];
  };
}
