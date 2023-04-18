{ self, config, lib, pkgs, ... }:

lib.mkIf config.services.cockpit.enable {

  services.nginx.virtualHosts."cockpit.${config.networking.hostName}.${config.networking.domain}" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.cockpit.port}";
      proxyWebsockets = true;
    };
  };

  # services.cockpit.settings = {
  #   WebService = {
  #     Origins = "http://cockpit.${config.networking.hostName}.${config.networking.domain}";
  #   };
  # };
}
