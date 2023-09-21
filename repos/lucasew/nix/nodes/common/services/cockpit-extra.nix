{ self, config, lib, pkgs, ... }:

lib.mkIf config.services.cockpit.enable {
  # networking.ports.cockpit.enable = true;

  services.nginx.virtualHosts."cockpit.${config.networking.hostName}.${config.networking.domain}" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.cockpit.port}";
      proxyWebsockets = true;
    };
  };

  services.cockpit = {
    # inherit (config.networking.ports.cockpit) port;
    settings = {
      WebService = {
        Origins = builtins.concatStringsSep " " [
          "http://cockpit.${config.networking.hostName}.${config.networking.domain}"
          "http://${config.networking.hostName}:${toString config.services.cockpit.port}"
          "https://${config.networking.hostName}:${toString config.services.cockpit.port}"
          "http://${config.networking.hostName}:${toString config.services.cockpit.port}"
          "https://${config.networking.hostName}:${toString config.services.cockpit.port}"
        ];
      };
    };
  };

  environment.etc."motd-bash.d/99-cockpit" = {
    source = "/run/cockpit/active.motd";
  };
}
