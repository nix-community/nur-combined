{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.unoconv;
in
{
  options.services.unoconv = {
    enable = mkEnableOption "Unoconv webservice";
    port = mkOption {
      type = types.port;
      default = 2002;
      description = "Port for unoconv to listen";
    };
  };
  config = mkIf cfg.enable {
    systemd.services.unoconv = {
      description = "Unoconv webservice";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = [ "${pkgs.unoconv}/bin/unoconv --listener --server=0.0.0.0 --port=${toString cfg.port}" ];
      };
    };
  };
}
