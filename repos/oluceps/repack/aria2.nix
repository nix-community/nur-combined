{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkIf
    ;

  cfg = config.repack.aria2;
in
{
  # options.repack.aria2 = {
  # };
  config = mkIf cfg.enable {
    systemd.user.services.aria2 = {
      description = "aria2 Daemon";
      restartIfChanged = true;
      serviceConfig = {
        Type = "simple";
        ExecStart = "${lib.getExe pkgs.aria2}/bin/aria2c";
        Restart = "on-failure";
        RestartSec = "20s";
        RestartSteps = "5";
        RestartMaxDelaySec = "2h";
        StartLimitBurst = 5;
        StartLimitIntervalSec = "60s";
      };
    };
  };
}
