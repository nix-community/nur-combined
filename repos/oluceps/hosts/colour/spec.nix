{ config, lib, pkgs, ... }:

{
  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
    dockerCompat = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 10d";
  };

  boot = {
    supportedFilesystems = [ "tcp_bbr" ];
    inherit ((import ../../boot.nix { inherit lib; }).boot) kernel;
  };

  services = {
    inherit ((import ../../services.nix
      (lib.base
        // { inherit pkgs config; })).services)
      openssh fail2ban;
  };

  programs = {
    git.enable = true;
    fish.enable = true;
  };

  systemd = {
    enableEmergencyMode = true;
    watchdog = {
      # systemd will send a signal to the hardware watchdog at half
      # the interval defined here, so every 10s.
      # If the hardware watchdog does not get a signal for 20s,
      # it will forcefully reboot the system.
      runtimeTime = "20s";
      # Forcefully reboot if the final stage of the reboot
      # hangs without progress for more than 30s.
      # For more info, see:
      #   https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdShutdownWatchdog
      rebootTime = "30s";
    };

  };

  systemd.tmpfiles.rules = [
  ];

  services = {
    juicity.instances = [{
      name = "only";
      serve = {
        enable = true;
        port = 23180;
      };
      configFile = config.age.secrets.juic-san.path;
    }];

    hysteria.instances = [
      {
        name = "only";
        serve = {
          enable = true;
          port = 4432;
        };
        configFile = config.age.secrets.hyst-us.path;
      }
    ];


    caddy = {
      enable = true;
      virtualHosts = {
        "api.atuin.nyaw.xyz" = {
          hostName = "api.atuin.nyaw.xyz";
          extraConfig = ''
            log {
              level DEBUG
            }
    
            tls mn1.674927211@gmail.com
            reverse_proxy 10.0.2.2:8888
          '';
        };
        "gpt4.nyaw.xyz" = {
          hostName = "gpt4.nyaw.xyz";
          extraConfig = ''
            tls mn1.674927211@gmail.com
            reverse_proxy 10.0.2.3:3000
          '';
        };
      };
    };
  };

  system.stateVersion = "24.05"; # Did you read the comment?

}
