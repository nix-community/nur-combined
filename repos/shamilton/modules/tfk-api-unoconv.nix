{ tfk-api-unoconv }:
{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.tfk-api-unoconv;
in
{
  options.services.tfk-api-unoconv = {
    enable = mkEnableOption "Tfk unoconv's API";
    port = mkOption {
      type = types.port;
      default = 2002;
      description = "Port for tfk-api-unoconv to listen";
    };
    maxPayloadSize = mkOption {
      type = types.ints.unsigned;
      default = 50; 
      description = "The max payload size to accept in MiB";
    };
  };
  config = mkIf cfg.enable {
    systemd.services.tfk-api-unoconv = {
      description = "Tfk unoconv's API";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      path = with pkgs; [ unoconv libreoffice-fresh ];
      environment = {
        PAYLOAD_MAX_SIZE = "${toString (cfg.maxPayloadSize*1048576)}";
        SERVER_PORT = toString cfg.port;
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = [ "${tfk-api-unoconv}/bin/tfk-api-unoconv" ];
      };
    };
  };
}
