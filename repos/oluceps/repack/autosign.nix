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
    systemd.user.timers = {
      autosign = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "*-*-* 13:13:00";
          RandomizedDelaySec = "1h";
          Persistent = true;
        };
      };
    };
    systemd.user.services.autosign = {
      description = "autosign Daemon";
      restartIfChanged = false;
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
        RestartSec = "20s";
        RestartSteps = "5";
        RestartMaxDelaySec = "2h";
        StartLimitBurst = 5;
      };
    };
  };
}
