{ config, lib, ... }:

with lib;

let
  cfg = config.my.services.tgv;
  my = config.my;
in
{
  options.my.services.tgv = {
    enable = lib.mkEnableOption "TGV redirect";
  };

  config = mkIf cfg.enable {
    services.nginx.virtualHosts = {
      "tgv.sexy" = {
        forceSSL = true;
        enableACME = true;

        locations."/".return = "301 http://www.mlgtraffic.net/";
      };
    };
  };
}
