{ config, ...}:

{
  services.nginx.virtualHosts."nix-cache.${config.networking.hostName}.${config.networking.domain}" = {
    locations."/".root = "/media/downloads/nix";
  };
}
