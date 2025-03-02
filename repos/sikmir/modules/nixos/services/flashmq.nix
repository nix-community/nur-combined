{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.flashmq;
in
{
  options.services.flashmq = {
    enable = mkEnableOption "flashmq";
  };

  config = mkIf cfg.enable {
    systemd.services.flashmq = {
      description = "FlashMQ MQTT server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        DynamicUser = true;
        LogsDirectory = "flashmq";
        LimitNOFILE = "infinity";
        ExecStart = "${cfg.flashmq}/bin/flashmq -c ${configFile}";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  };
}
