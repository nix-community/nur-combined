{ ... }:
let
  port = 19564;
  address = "127.13.239.252";
in
{
  services.nitter = {
    enable = true;
    redisCreateLocally = true;
    openFirewall = false;
    settings = { };
    server.title = "fireshape";
    server.port = port;
    server.https = true;
    server.hostname = "nitter.shelvacu.com";
    server.address = address;
    preferences.hlsPlayback = true;
    preferences.autoplayGifs = false;
    config.tokenCount = 2;
  };

  services.redis.servers.nitter = {
    unixSocket = null;
  };

  systemd.services.nitter = {
    serviceConfig = {
      SocketBindAllow = "ipv4:tcp:${toString port}";
      SocketBindDeny = "any";
    };
  };
}
