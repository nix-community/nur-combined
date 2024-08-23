{ pkgs, ... }:

{
  imports = [
    ./gnome
    ./fonts
    ./rime
    ./hardware.nix
    ./services.nix
    ./virt.nix
    ./networking.nix
    ./sops.nix
    ./lanzaboote.nix
    ./btrbk.nix
  ];
  # xdg.portal = {
  #   enable = true;
  #   extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
  # };
  # systemd = {
  #   user.services.polkit-gnome-authentication-agent-1 = {
  #     description = "polkit-gnome-authentication-agent-1";
  #     wantedBy = [ "graphical-session.target" ];
  #     wants = [ "graphical-session.target" ];
  #     after = [ "graphical-session.target" ];
  #     serviceConfig = {
  #       Type = "simple";
  #       ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
  #       Restart = "on-failure";
  #       RestartSec = 1;
  #       TimeoutStopSec = 10;
  #     };
  #   };
  # };

  # stylix.enable = true;

  chaotic = {
    scx.enable = true;
    scx.scheduler = "scx_lavd";
  };

  boot = {
    plymouth.enable = true;
    loader = {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 5;
      efi.canTouchEfiVariables = false; # @TODO
    };
    # kernelPackages = pkgs.linuxPackages_latest;
    kernelPackages = pkgs.chaotic.linuxPackages_cachyos;
    #@TODO
    kernelParams = [
      # Lenovo shit do not support on 4xxx
      # "amd_pstate=active"
      "ideapad_laptop.allow_v4_dytc=1"
      "pti=on"
      "log_level=3"
      "nowatchdog"
    ];
    supportedFilesystems = [ "ntfs" ];
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.sessionVariables.TERMINAL = [ "kitty" ];

  time.timeZone = "Asia/Shanghai";

  i18n = {
    defaultLocale = "zh_CN.UTF-8";
    supportedLocales = [
      "zh_CN.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];
  };
  # security.pam.services.swaylock = {
  #   text = ''
  #     auth include login
  #   '';
  # };

  nixpkgs.config.allowUnfree = true;

  environment.pathsToLink = [ "/share/fish" ];

  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var"
      "/root"
      "/etc/NetworkManager/system-connections"
      "/etc/secureboot"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_ed25519_key"
    ];
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.fish.enable = true;
  #programs.thefuck.enable = true;
  programs.adb.enable = true;
  programs.fuse.userAllowOther = true;
  services.flatpak.enable = true;

  systemd.services.nix-daemon = {
    environment = {
      TMPDIR = "/var/cache/nix";
    };
    serviceConfig = {
      CacheDirectory = "nix";
    };
  };

  documentation.nixos.enable = false;

  system.stateVersion = "23.11";
}
