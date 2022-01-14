{ config, lib, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
  ;

  cfg = config.my.services.nuage;
  my = config.my;
in
{
  options.my.services.nuage = {
    enable = mkEnableOption "Nuage redirect";
  };

  config = mkIf cfg.enable {
    services.nginx.virtualHosts = {
      "stratocumulus.org" = {
        forceSSL = true;
        enableACME = true;

        locations."/".return = "301 https://petit-nuage.org";
      };
      "petit.stratocumulus.org" = {
        forceSSL = true;
        enableACME = true;

        locations."/".return = "301 https://petit-nuage.org";
      };
      "gros.stratocumulus.org" = {
        forceSSL = true;
        enableACME = true;

        locations."/".return = "301 https://gros-nuage.org";
      };
    };
  };
}
