{
  self,
  config,
  lib,
  pkgs,
  ...
}:

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

  systemd.services =
    let
      units = [
        "cockpit-wsinstance-https@"
        "cockpit-wsinstance-https-factory@"
        "cockpit-wsinstance-http"
        "cockpit"
        "cockpit-motd"
      ];
    in
    lib.listToAttrs (
      map (unit: {
        name = unit;
        value.serviceConfig = {
          MemoryHigh = "512M";
          MemoryMax = "1G";
        };
      }) units
    );

  environment.etc."motd-bash.d/99-cockpit" = {
    source = "/run/cockpit/active.motd";
  };
}
