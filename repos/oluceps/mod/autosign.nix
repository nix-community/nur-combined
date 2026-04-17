{
  flake.modules.nixos.autosign =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      scriptPath = config.fn.readToStore ../../../script/autosign.ts;
    in
    {
      options.autosign.environmentFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      config = {
        systemd.user.timers.autosign = {
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = "*-*-* 13:13:00";
            RandomizedDelaySec = "1h";
            Persistent = true;
          };
        };
        systemd.user.services.autosign = {
          description = "autosign Daemon";
          restartIfChanged = false;
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${lib.getExe pkgs.deno} run --allow-env --allow-net --no-check ${scriptPath}";
            EnvironmentFile = config.autosign.environmentFile;
            Environment = [ "HOME=/home/${config.identity.user}" ];
            Restart = "on-failure";
            RestartSec = "20s";
            RestartSteps = "5";
            RestartMaxDelaySec = "2h";
            StartLimitBurst = 5;
          };
        };
      };
    };
}
