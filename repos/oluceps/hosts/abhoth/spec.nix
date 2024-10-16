{
  config,
  lib,
  ...
}:
{

  system.stateVersion = "24.05";

  users.mutableUsers = false;
  services.userborn.enable = true;
  system.etc.overlay.enable = true;
  system.etc.overlay.mutable = false;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1d";
  };

  boot = {
    supportedFilesystems = [ "tcp_bbr" ];
    inherit ((import ../sysctl.nix { inherit lib; }).boot) kernel;
  };

  repack = {
    openssh.enable = true;
    fail2ban.enable = true;
    dnsproxy = {
      enable = true;
      extraFlags = [ "--ipv6-disabled" ];
    };
    # rustypaste.enable = true;
  };
  services = {
    dnsproxy.settings = lib.mkForce {
      bootstrap = [
        "1.1.1.1"
        "8.8.8.8"
      ];
      listen-addrs = [ "0.0.0.0" ];
      listen-ports = [ 53 ];
      upstream-mode = "load_balance";
      upstream = [
        "1.1.1.1"
        "8.8.8.8"
        "https://dns.google/dns-query"
      ];
    };
    metrics.enable = true;
    trojan-server.enable = true;

    hysteria.instances = {
      only = {
        enable = true;
        serve = true;
        openFirewall = 4432;
        credentials = [
          "key:${config.age.secrets."nyaw.key".path}"
          "cert:${config.age.secrets."nyaw.cert".path}"
        ];
        configFile = config.age.secrets.hyst-us.path;
      };
    };

    realm = {
      enable = true;
      settings = {
        log.level = "warn";
        network = {
          no_tcp = false;
          use_udp = true;
        };
        endpoints = [
          {
            listen = "[::]:34197";
            remote = "144.126.208.183:34197";
          }
        ];
      };
    };
  };
}
