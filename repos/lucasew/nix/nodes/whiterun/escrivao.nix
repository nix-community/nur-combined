{ config, lib, ... }:

let
  cfg = config.services.escrivao;
  workerName = "stt-ptbr";
  workerSocket = "${config.services.python-microservices.socketDirectory}/${workerName}";
in

{
  config = lib.mkIf cfg.enable {
    services.escrivao = {
      tokenFile = "/run/secrets/escrivao-token";
      extraArgs = [
        "--worker-socket"
        workerSocket
      ];
    };
    sops.secrets.escrivao-token = {
      sopsFile = ../../secrets/escrivao-token;
      owner = config.users.users.${cfg.user}.name;
      group = config.users.users.${cfg.user}.group;
      format = "binary";
    };
    systemd.services.escrivao = {
      after = [ "${config.services.python-microservices.services.${workerName}.unitName}.socket" ];
    };
  };
}
