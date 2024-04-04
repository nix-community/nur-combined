{
  config,
  lib,
  pkgs,
  ...
}:

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
    inherit ((import ../sysctl.nix { inherit lib; }).boot) kernel;
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

  systemd.tmpfiles.rules = [ ];

  services =
    (
      let
        importService = n: import ../../services/${n}.nix { inherit pkgs config lib; };
      in
      lib.genAttrs [
        "openssh"
        "fail2ban"
        "prometheus"
      ] (n: importService n)
    )
    // {

      prom-ntfy-bridge.enable = true;
      metrics.enable = true;
      juicity.instances = [
        {
          name = "only";
          credentials = [
            "key:${config.age.secrets."nyaw.key".path}"
            "cert:${config.age.secrets."nyaw.cert".path}"
          ];
          serve = true;
          openFirewall = 23180;
          configFile = config.age.secrets.juic-san.path;
        }
      ];
      hysteria.instances = [
        {
          name = "only";
          serve = {
            enable = true;
            port = 4432;
          };
          credentials = [
            "key:${config.age.secrets."nyaw.key".path}"
            "cert:${config.age.secrets."nyaw.cert".path}"
          ];
          configFile = config.age.secrets.hyst-us.path;
        }
      ];
    };

  system.stateVersion = "24.05"; # Did you read the comment?
}
