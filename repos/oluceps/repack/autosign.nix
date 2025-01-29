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
    systemd.user.timers.autosign = {
      description = "autosign";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 11:30:00";
        RandomizedDelaySec = "5m";
        Persistent = true;
      };
    };
    systemd.user.services.autosign = {
      after = [
        "network-online.target"
        "nss-lookup.target"
      ];
      wants = [
        "network-online.target"
        "nss-lookup.target"
      ];
      description = "autosign Daemon";
      restartIfChanged = false;
      serviceConfig = {
        Type = "oneshot";
        # DynamicUser = true;
        ExecStart =
          let
            scriptPath = ../script/autosign.ts;
          in
          "${lib.getExe pkgs.deno} run --allow-env --allow-net --no-check ${scriptPath}";
        EnvironmentFile = cfg.environmentFile;
        Restart = "no";
      };
    };
  };
}
