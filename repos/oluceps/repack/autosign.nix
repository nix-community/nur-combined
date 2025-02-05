{
  user,
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    mkIf
    ;

  cfg = config.repack.autosign;
in
{
  options.repack.autosign = {
    environmentFile = mkOption {
      type = types.nullOr types.str;
      default = config.vaultix.secrets.autosign.path;
    };
  };
  config = mkIf cfg.enable {
    systemd.user.services.autosign = {
      description = "autosign Daemon";
      restartIfChanged = false;
      startAt = "*-*-* 13:10:00";
      serviceConfig = {
        Type = "oneshot";
        ExecStart =
          let
            scriptPath = ../script/autosign.ts;
          in
          "${lib.getExe pkgs.deno} run --allow-env --allow-net --no-check ${scriptPath}";
        EnvironmentFile = cfg.environmentFile;
        Environment = [ "HOME=/home/${user}" ];
        Restart = "on-failure";
        RestartSec = "5s";
        StartLimitBurst = 3;
        StartLimitInterval = "60s";
      };
    };
  };
}
