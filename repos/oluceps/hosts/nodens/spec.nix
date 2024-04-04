{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
{
  # server.

  system.stateVersion = "22.11";

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 10d";
  };

  boot = {
    supportedFilesystems = [ "tcp_bbr" ];
    inherit ((import ../sysctl.nix { inherit lib; }).boot) kernel;
  };

  environment.systemPackages = with pkgs; [ factorio-headless ];

  systemd.services.trojan-server.serviceConfig.LoadCredential = (map (lib.genCredPath config)) [
    "nyaw.cert"
    "nyaw.key"
  ];

  srv = {
    openssh = true;
    fail2ban = true;
    rustypaste = true;
  };
  services = {
    metrics.enable = true;
    trojan-server.enable = true;
    do-agent.enable = true;
    # copilot-gpt4.enable = true;
    factorio-manager = {
      enable = true;
      factorioPackage = pkgs.factorio-headless-experimental;
      botConfigPath = config.age.secrets.factorio-manager-bot.path;
      initialGameStartArgs = [
        "--server-settings=${config.age.secrets.factorio-server.path}"
        "--server-adminlist=${config.age.secrets.factorio-admin.path}"
      ];
    };

    ntfy-sh = {
      enable = true;
      settings = {
        listen-http = ":2586";
        behind-proxy = true;
        auth-default-access = "deny-all";
        base-url = "http://ntfy.nyaw.xyz";
      };
    };

    online-keeper.instances = [
      {
        name = "sec";
        sessionFile = config.age.secrets.tg-session.path;
        environmentFile = config.age.secrets.tg-env.path;
      }
    ];

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
