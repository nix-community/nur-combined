{
  config,
  pkgs,
  lib,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    lsof
    wireguard-tools
    tcpdump
  ];
  system = {
    # server inside the cage.

    stateVersion = "24.05";
    etc.overlay.enable = true;
    etc.overlay.mutable = false;
  };

  vaultix.templates = {
    hyst-osa = {
      content =
        config.vaultix.placeholder.hyst-osa-cli
        + (
          let
            port = toString (lib.conn { }).${config.networking.hostName}.abhoth;
          in
          ''
            socks5:
              listen: 127.0.0.1:1091
            udpForwarding:
            - listen: 127.0.0.1:${port}
              remote: 127.0.0.1:${port}
              timeout: 120s
          ''
        );
      owner = "root";
      group = "users";
      name = "osa.yaml";
      trim = false;
    };
    hyst-yi = {
      content =
        config.vaultix.placeholder.hyst-yi-cli
        + (
          let
            port = toString (lib.conn { }).${config.networking.hostName}.yidhra;
          in
          ''
            socks5:
              listen: 127.0.0.1:1092
            udpForwarding:
            - listen: 127.0.0.1:${port}
              remote: 127.0.0.1:${port}
              timeout: 120s
          ''
        );
      owner = "root";
      group = "users";
      name = "hk.yaml";
      trim = false;
    };
  };
  users.mutableUsers = false;
  environment.etc."resolv.conf".text = ''
    nameserver 127.0.0.1
  '';

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 3d";
  };

  boot = {
    supportedFilesystems = [ "tcp_bbr" ];
    inherit ((import ../sysctl.nix { inherit lib; }).boot) kernel;
  };
  repack = {
    plugIn.enable = true;
    openssh.enable = true;
    fail2ban.enable = true;
    dae.enable = false;
    srs.enable = true;
    dnsproxy = {
      enable = true;
      extraFlags = [ "--ipv6-disabled" ];
    };
  };
  services = {
    userborn.enable = true;

    sing-box.enable = true;
    metrics.enable = true;

    realm = {
      enable = true;
      settings = {
        log.level = "warn";
        network = {
          no_tcp = false;
          use_udp = true;
        };
        endpoints = [

        ];
      };
    };

    shadow-tls.instances = {
      relay = {
        enable = true;
        configFile = config.vaultix.secrets.shadow-tls-relay.path;
        openFirewall = 32193;
        serve = true;
      };
    };
    hysteria.instances = {
      # nodens = {
      #   enable = true;
      #   configFile = config.vaultix.secrets.hyst-us-cli.path;
      # };
      abhoth = {
        enable = true;
        configFile = config.vaultix.templates.hyst-osa.path;
      };
      yidhra = {
        enable = true;
        configFile = config.vaultix.templates.hyst-yi.path;
      };
    };
  };

  networking.firewall = {
    allowedUDPPorts = [ 6059 ];
    allowedTCPPorts = [ 6059 ];
  };

  programs = {
    git.enable = true;
    fish.enable = true;
  };
  zramSwap = {
    enable = true;
    swapDevices = 1;
    memoryPercent = 80;
    algorithm = "zstd";
  };

  systemd = {
    enableEmergencyMode = false;
    watchdog = {
      # systemd will send a signal to the hardware watchdog at half
      # the interval defined here, so every 10s.
      # If the hardware watchdog does not get a signal for 20s,
      # it will forcefully reboot the system.
      settings.Manager = {
        RebootWatchdogSec = "20s";
        RuntimeWatchdogSec = "30s";
      };
    };
  };

  systemd.tmpfiles.rules = [ ];
}
