# Groceries and household management
{ config, lib, ... }:
let
  cfg = config.my.services.grocy;
  grocyDomain = "grocy.${config.networking.domain}";
in
{
  options.my.services.grocy = with lib; {
    enable = mkEnableOption "Grocy household ERP";
  };

  config = lib.mkIf cfg.enable {
    services.grocy = {
      enable = true;

      # The service sets up the reverse proxy automatically
      hostName = grocyDomain;

      # Configure SSL by hand
      nginx = {
        enableSSL = false;
      };

      settings = {
        currency = "EUR";
        culture = "en";
        calendar = {
          # Start on Monday
          firstDayOfWeek = 1;
          showWeekNumber = true;
        };
      };
    };

    services.nginx.virtualHosts."${grocyDomain}" = {
      forceSSL = true;
      useACMEHost = config.networking.domain;
    };
  };
}
