{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.prom-ntfy-bridge;
in
{
  options.services.prom-ntfy-bridge = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    environment = mkOption {
      type = types.listOf types.str;
      default = [
        "TOPIC=https://ntfy.nyaw.xyz/crit"
        "PORT=8009"
        "DENO_DIR=/tmp"
      ];
    };
  };
  config = mkIf cfg.enable {
    systemd.services.prom-ntfy-bridge = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      description = "prom-ntfy-bridge Daemon";
      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        ExecStart =
          let
            scriptPath = ../fn/alert.ts;
          in
          "${lib.getExe pkgs.deno} run --allow-env --allow-net --no-check ${scriptPath}";
        Environment = cfg.environment;
        Restart = "on-failure";
      };
    };
  };
}
