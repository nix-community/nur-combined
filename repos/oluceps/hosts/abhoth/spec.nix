{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
{
  # server inside the cage.

  system.stateVersion = "23.05";

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 3d";
  };

  boot = {
    supportedFilesystems = [ "tcp_bbr" ];
    inherit ((import ../sysctl.nix { inherit lib; }).boot) kernel;
  };

  environment.systemPackages = with pkgs; [ factorio-headless ];

  services =
    (
      let
        importService = n: import ../../services/${n}.nix { inherit pkgs config inputs; };
      in
      lib.genAttrs [
        "openssh"
        "mosdns"
        "fail2ban"
        "dae"
      ] (n: importService n)
    )
    // {
      sing-box.enable = true;

      juicity.instances = [
        {
          name = "only-cli";
          configFile = config.age.secrets.jc-do.path;
        }
      ];

      realm = {
        enable = true;
        settings = {
          endpoints = [
            {
              local = "0.0.0.0:5000";
              remote = "nyaw.xyz:4432";
            }
          ];
        };
      };
      shadowsocks.instances = [
        {
          name = "abh";
          configFile = config.age.secrets.ss-az.path;
          serve = {
            enable = true;
            port = 6059;
          };
        }
      ];

      factorio = {
        enable = false;
        openFirewall = false;
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
      runtimeTime = "20s";
      # Forcefully reboot if the final stage of the reboot
      # hangs without progress for more than 30s.
      # For more info, see:
      #   https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdShutdownWatchdog
      rebootTime = "30s";
    };
  };

  systemd.tmpfiles.rules = [ ];
}
