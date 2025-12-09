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
    (curlECH.override {
      ldapSupport = true;
      gsaslSupport = true;
      rtmpSupport = true;
      pslSupport = true;
      websocketSupport = true;
      echSupport = true;
    })
  ];
  system = {
    stateVersion = "25.05";
    etc.overlay.enable = true;
    etc.overlay.mutable = false;
  };

  users.mutableUsers = false;
  services.userborn.enable = true;

  ## START FOR other user
  networking.nftables = {
    enable = true;
    ruleset = ''
      table inet filter {
        chain output {
        	type filter hook output priority filter; policy accept;
        	ip6 daddr fdcc::/16 meta skuid 1010 reject with icmpv6 port-unreachable
        }
      }
    '';
  };
  users.users.zgmx = {
    isNormalUser = true;
    uid = 1010;
    subUidRanges = [
      {
        count = 65536;
        startUid = 2147483646;
      }
    ];
    subGidRanges = [
      {
        count = 65536;
        startGid = 2147483647;
      }
    ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMgaKPBtVDqxgse2UdlsGM7LdRxq+uSJV7FPhC1LyyXJ"
    ];
  };
  ## END FOR other user
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

    userborn-subid.enable = true;
  };
  services = {
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
    metrics.enable = true;

    hysteria.instances = {
      only = {
        enable = true;
        serve = true;
        openFirewall = 4432;
        credentials = [
          # signed by my ca
          "key:${config.vaultix.secrets."nyaw.key".path}"
          "crt:${config.vaultix.secrets."nyaw.cert".path}"
        ];
        configFile = config.vaultix.secrets.hyst-us.path;
      };
    };
  };
}
