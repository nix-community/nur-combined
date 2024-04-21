{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf;
in

{
  config = mkIf config.services.transmission.enable {
    networking.ports = {
      transmission-000.enable = true;
      transmission-001.port = config.networking.ports.transmission-000.port - 1;
      transmission-002.port = config.networking.ports.transmission-000.port - 2;
      transmission-003.port = config.networking.ports.transmission-000.port - 3;
      transmission-004.port = config.networking.ports.transmission-000.port - 4;
      transmission-005.port = config.networking.ports.transmission-000.port - 5;
      transmission-006.port = config.networking.ports.transmission-000.port - 6;
      transmission-007.port = config.networking.ports.transmission-000.port - 7;
      transmission-008.port = config.networking.ports.transmission-000.port - 8;
      transmission-009.port = config.networking.ports.transmission-000.port - 9;
      transmission-999.port = config.networking.ports.transmission-000.port - 10;
      # transmission-000 = { enable = true; port = 49120;}; # highest port
      # transmission-001 = { enable = true; port = 49119;};
      # transmission-002 = { enable = true; port = 49118;};
      # transmission-003 = { enable = true; port = 49117;};
      # transmission-004 = { enable = true; port = 49116;};
      # transmission-005 = { enable = true; port = 49115;};
      # transmission-006 = { enable = true; port = 49114;};
      # transmission-007 = { enable = true; port = 49113;};
      # transmission-008 = { enable = true; port = 49112;};
      # transmission-009 = { enable = true; port = 49111;};
      # transmission-999 = { enable = true; port = 49110;}; # lowest port
      transmission-rpc.enable = true;
      transmission-rpc.port = 9091; # Nextcloud actually expects a stable port
      # transmission-rpc  = { enable = true; port = 49109;};
    };
    systemd.services.transmission = {
      serviceConfig = {
        MemoryHigh = "1G";
        MemoryMax = "2G";
      };
    };
    services.transmission = {
      openFirewall = true;
      openPeerPorts = true;
      downloadDirPermissions = null;
      webHome = pkgs.flood-for-transmission;
      settings = {
        peer-port-random-on-start = true;
        peer-port-random-low = config.networking.ports.transmission-999.port;
        peer-port-random-high = config.networking.ports.transmission-000.port;
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
