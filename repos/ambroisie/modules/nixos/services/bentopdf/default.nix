{ config, lib, ... }:
let
  cfg = config.my.services.bentopdf;
in
{
  options.my.services.bentopdf = with lib; {
    enable = mkEnableOption "BentoPDF service";
  };

  config = lib.mkIf cfg.enable {
    services.bentopdf = lib.mkIf cfg.enable {
      enable = true;

      domain = "bentopdf.${config.networking.domain}";

      nginx = {
        enable = true;

        # The service configures the domain, no need for my wrapper
        virtualHost = {
          forceSSL = true;
          useACMEHost = config.networking.domain;
        };
      };
    };
  };
}
