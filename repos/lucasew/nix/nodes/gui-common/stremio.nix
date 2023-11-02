{ config, ... }:
# stremio web seems to always host the streaming server in port 11470

{
  services.nginx.virtualHosts."stremio.${config.networking.hostName}.${config.networking.domain}" = {
    locations."/" = {
      proxyPass = "http://localhost:11470";
      proxyWebsockets = true;
    };
  };
}
