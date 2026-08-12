{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.opencodex;
  stateDir =
    if cfg.stateDir != null then
      cfg.stateDir
    else if config.home.preferXdgDirectories then
      "${config.xdg.dataHome}/opencodex"
    else
      "~/.opencodex";
in
{
  imports = [ ../common/opencodex.nix ];

  config = mkIf cfg.enable {
    systemd.user.services.opencodex = {
      Unit = {
        Description = "OpenCodex Proxy Server";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
      Service = {
        ExecStart = "${getExe cfg.package} start --port ${toString cfg.port}";
        Restart = "on-failure";
        RestartSec = "5s";
        Environment = [
          "OPENCODEX_HOME=${stateDir}"
        ]
        ++ optional (cfg.codexHome != null) "CODEX_HOME=${cfg.codexHome}"
        ++ (mapAttrsToList (name: value: "${name}=${value}") cfg.extraEnvironment);
        NoNewPrivileges = true;
        RestrictSUIDSGID = true;
        UMask = "0077";
      }
      // optionalAttrs (cfg.environmentFile != null) { EnvironmentFile = cfg.environmentFile; };
    };

    systemd.user.tmpfiles.rules = [ "d ${stateDir} 0700 - - -" ];
  };
}
