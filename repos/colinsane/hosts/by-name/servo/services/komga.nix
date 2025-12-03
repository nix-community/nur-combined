{ config, lib, ... }:
let
  svc-cfg = config.services.komga;
  inherit (svc-cfg) user group port stateDir;
in
lib.mkIf false  #< 2024/09/30: disabled because i haven't used this for several months
{
  sane.persist.sys.byStore.plaintext = [
    { inherit user group; mode = "0700"; path = stateDir; method = "bind"; }
  ];

  services.komga.enable = true;
  services.komga.port = 11319;  # chosen at random

  services.nginx.virtualHosts."komga.uninsane.org" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${builtins.toString port}";
      recommendedProxySettings = true;
    };
    locations."= /robots.txt".extraConfig = ''
      return 200 "User-agent: *\nDisallow: /\n";
    '';
  };
  sane.dns.zones."uninsane.org".inet.CNAME."komga" = "native";
}
