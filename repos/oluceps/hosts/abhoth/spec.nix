{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    lsof
    wireguard-tools
    tcpdump
  ];
  system = {
    stateVersion = "25.05";
    etc.overlay.enable = true;
    etc.overlay.mutable = false;
  };

  users.mutableUsers = false;
  services.userborn.enable = true;

  zramSwap = {
    enable = true;
    memoryPercent = 80;
    algorithm = "zstd";
  };
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
    plugIn.enable = true;
    openssh.enable = true;
    fail2ban.enable = true;
    # dnsproxy = {
    #   enable = true;
    # };
    sing-server.enable = true;
    # snm.enable = true;
    stalwart.enable = true;
  };
  services = {
    yggdrasil.settings.AllowedPublicKeys = [
      "870b1f8c965df2b3220d9d6e4e8457f8f025f641873d00266adb3275d9025f14"
    ];
    # dnsproxy.settings = lib.mkForce {
    #   bootstrap = [
    #     "1.1.1.1"
    #     "8.8.8.8"
    #   ];
    #   listen-addrs = [ "0.0.0.0" ];
    #   listen-ports = [ 53 ];
    #   upstream-mode = "load_balance";
    #   upstream = [
    #     "1.1.1.1"
    #     "8.8.8.8"
    #     "https://dns.google/dns-query"
    #   ];
    # };
    metrics.enable = true;
    qemuGuest.enable = true;

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
            listen = "[::]:8776";
            remote = "[fdcc::3]:8776";
          }
        ];
      };
    };
  };
}
