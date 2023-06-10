{ config, lib, ... }:

let
  inherit (lib) mkIf;
in

{
  config = mkIf config.services.transmission.enable {
    networking.ports = {
      transmission-0000.enable = true; # highest port
      transmission-0001.enable = true;
      transmission-0002.enable = true;
      transmission-0003.enable = true;
      transmission-0004.enable = true;
      transmission-0005.enable = true;
      transmission-0006.enable = true;
      transmission-0007.enable = true;
      transmission-0008.enable = true;
      transmission-0009.enable = true;
      transmission-0010.enable = true;
      transmission-9999.enable = true; # lowest port
      transmission-rpc.enable = true; # lowest port
    };
    services.transmission = {
      openFirewall = true;
      openPeerPorts = true;
      settings = {
        peer-port-random-on-start = true;
        peer-port-random-low = config.networking.ports.transmission-9999.port;
        peer-port-random-high = config.networking.ports.transmission-0000.port;
        rpc-port = config.networking.ports.transmission-rpc.port;
        message-level = 3; # journalctl all the things, hope it doesnt spam
        utp-enabled = true;
      };
    };
    services.nginx.virtualHosts."transmission.${config.networking.hostName}.${config.networking.domain}" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.transmission.settings.rpc-port}";
      };
    };
  };
}
