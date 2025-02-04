# original from NickCao/flakes
{
  pkgs,
  user,
  config,
  lib,
  ...
}:
let
  cfg = config.repack.subs;
in
{

  options = {
    repack.subs = {
      scriptPath = lib.mkOption {
        type = lib.types.str;
        default = config.vaultix.secrets.subs.path;
      };
    };
  };

  config = lib.mkIf cfg.enable {

    systemd.user.services.subs = {
      unitConfig = {
        StartLimitIntervalSec = 0;
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = "${lib.getExe pkgs.deno} run --allow-env --allow-net --no-check ${cfg.scriptPath}";
        Environment = [ "HOME=/home/${user}" ];
        Restart = "always";
        RestartSec = 1;
      };
      wantedBy = [ "default.target" ];
      after = [
        "network.target"
      ];
    };
  };
}
