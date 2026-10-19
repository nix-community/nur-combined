{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./homelab.nix
    ../../../modules/hardware/a64
  ];

  nix-mineral.enable = lib.mkForce false;
  programs.nix-index.enable = lib.mkForce false;
  programs.nix-index-database.comma.enable = lib.mkForce false;
  services.smartd.enable = lib.mkForce false;

  boot.tmp.cleanOnBoot = true;

  services.openssh.settings.PermitRootLogin = lib.mkForce "yes";

  networking.hostName = "apollo13";

  sops.secrets.wifi-password = {
    sopsFile = ../../../secrets/secrets.yaml;
    key = "wifi/password";
  };
  sops.templates."wireless.conf" = {
    content = ''
      psk_samosa=${config.sops.placeholder.wifi-password}
    '';
    owner = "wpa_supplicant";
    mode = "0400";
  };
  networking.wireless = {
    enable = true;
    interfaces = [ "wlan0" ];
    secretsFile = config.sops.templates."wireless.conf".path;
    networks."samosa".pskRaw = "ext:psk_samosa";
  };

  environment.systemPackages = with pkgs; [
    iw
  ];

  services.tailscale.enable = true;
  services.timesyncd.enable = lib.mkForce true;
  services.getty.autologinUser = "avy";

  # SD card storage is the tightest resource on this device, so garbage
  # collect and dedup aggressively rather than the repo-wide weekly/7d
  # defaults in modules/nix.
  nix = {
    settings = {
      min-free = lib.mkForce (128 * 1024 * 1024);
      max-free = lib.mkForce (1024 * 1024 * 1024);
    };
    gc = {
      automatic = lib.mkForce true;
      dates = lib.mkForce "daily";
      options = lib.mkForce "-d --delete-older-than 3d";
    };
    optimise = {
      automatic = lib.mkForce true;
      dates = lib.mkForce [ "daily" ];
    };
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 4 * 1024; # size in MiB
    }
  ];

  users = {
    mutableUsers = false;
    users.root.password = "root";
    users.avy.hashedPassword = "!";
  };

  system.stateVersion = "25.05";
}
