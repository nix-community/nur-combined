{
  self,
  pkgs,
  config,
  ...
}:
let
  hostname = "riverwood";
in
{
  imports = [
    ./hardware-configuration.nix
    ../gui-common

    "${self.inputs.nixos-hardware}/common/cpu/intel"
    "${self.inputs.nixos-hardware}/common/gpu/intel/kaby-lake"
    "${self.inputs.nixos-hardware}/common/pc/laptop"

    ./kvm.nix
    ./networking.nix
    ./sshfs.nix
    ./remote-build.nix
    ./tuning.nix
    ./earlyoom.nix
    ./plymouth.nix
  ];


  boot = {
    extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
    kernelModules = [ "v4l2loopback" ];
    # exclusive_caps precisa pro chromium detectar
    # devices é o número de câmeras virtuais
    extraModprobeConfig = ''
      options v4l2loopback devices=1 exclusive_caps=1
    '';
  };

  environment.systemPackages = with pkgs; [
    gparted
    git-annex
    git-remote-gcrypt
  ];

  programs.nix-ld.enable = true;

  programs.sway.enable = true;

  services.sunshine.enable = true;

  programs.gamemode.enable = true;

  services.flatpak.enable = true;

  networking.networkmanager.wifi.scanRandMacAddress = true;
  services.cockpit.enable = true;

  services.telegram-sendmail.enable = true;

  services.cloud-savegame = {
    enable = true;
    calendar = "01:00:01";
  };

  programs.steam.enable = true;

  services.xserver.xkb.model = "acer_laptop";

  virtualisation.kvmgt.enable = false;
  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.containerd.enable = true;

  # programs.steam.enable = true;

  programs.kdeconnect.enable = true;

  boot = {
    supportedFilesystems = [ "ntfs" ];
    loader = {
      efi = {
        canTouchEfiVariables = true;
      };
      grub = {
        efiSupport = true;
        #efiInstallAsRemovable = true; # in case canTouchEfiVariables doesn't work for your system
        device = "nodev";
        useOSProber = true;
      };
    };
  };

  gc-hold = {
    enable = true;
    paths = with pkgs; [
      gnumake
      cmake
      clang
      gdb
      ccls
    ];
  };

  services.hardware.openrgb.enable = true;

  networking.hostName = hostname; # Define your hostname.

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;

  environment.dotd."/etc/trab/nhaa".enable = true;
  services.screenkey.enable = true;

  sops.secrets.claude-code = {
    sopsFile = ../../../secrets/claude-code.env;
    owner = config.users.users.lucasew.name;
    group = config.users.users.lucasew.group;
    format = "dotenv";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}
