{
  config,
  lib,
  ...
}:
{
  system = {
    stateVersion = "25.05";
    etc.overlay.enable = true;
    etc.overlay.mutable = false;
  };

  users.mutableUsers = false;
  services.userborn.enable = true;

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
    };
    sing-server.enable = true;
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

    hysteria.instances = {
      only = {
        enable = true;
        serve = true;
        openFirewall = 4432;
        credentials = [
          "key:${config.vaultix.secrets."nyaw.key".path}"
          "crt:${config.vaultix.secrets."nyaw.cert".path}"
        ];
        configFile = config.vaultix.secrets.hyst-us.path;
      };
    };
  };
}
