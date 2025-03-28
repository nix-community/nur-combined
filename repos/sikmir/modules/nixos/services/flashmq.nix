{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.flashmq;
  description = "FlashMQ MQTT server";
in
{
  options.services.flashmq = {
    enable = mkEnableOption description;
    package = mkPackageOption pkgs "flashmq" { };
  };

  config = mkIf cfg.enable {
    systemd.services.flashmq = {
      inherit description;
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        DynamicUser = true;
        LogsDirectory = "flashmq";
        LimitNOFILE = "infinity";
        ExecStart = "${lib.getExe cfg.package} -c ${configFile}";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  };
}
