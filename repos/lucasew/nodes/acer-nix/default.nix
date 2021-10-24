# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{self, global, pkgs, config, lib, ... }:
let
  inherit (self) inputs;
  inherit (global) wallpaper username;
  hostname = "acer-nix";
in
{
  imports =
    [
      ../common/default.nix
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/gui/system.nix
      ../../modules/polybar/system.nix
      inputs.nix-ld.nixosModules.nix-ld
      inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
      inputs.nixos-hardware.nixosModules.common-cpu-intel-kaby-lake
    ]
  ;

  services.xserver.modules = with pkgs.xorg; [
    xf86inputjoystick
  ];

  # programs.steam.enable = true;

  nixpkgs = {
    config = {
      android_sdk.accept_license = true;
    };
  };

  # Use the systemd-boot EFI boot loader.
  boot.supportedFilesystems = [ "ntfs" ];
  boot.loader = {
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

  services.xserver.displayManager.lightdm.background = wallpaper;

  services.auto-cpufreq.enable = true;
  # text expander in rust
  services.espanso.enable = true;

  networking.hostName = hostname; # Define your hostname.
  networking.networkmanager.enable = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp2s0f1.useDHCP = true;
  networking.interfaces.wlp3s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    gparted
    paper-icon-theme
    kde-gtk-config # Custom
    # dasel # manipulação de json, toml, yaml, xml, csv e tal
    rclone-browser rclone restic # cloud storage
    p7zip unzip # archiving
    virt-manager
    # Extra
    custom.send2kindle
    intel-compute-runtime # OpenCL
  ];

  programs.dconf.enable = true;
  services.dbus.packages = with pkgs; [ gnome3.dconf ];
  services.gvfs.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.ssh.startAgent = true;
  programs.gnupg.agent = {
    enable = true;
    # enableSSHSupport = true;
    pinentryFlavor = "gnome3";
  };
  hardware = {
    bluetooth.enable = true;
    opengl = {
      enable = true;
      driSupport32Bit = true;
      extraPackages32 = with pkgs.pkgsi686Linux; [
        vaapiIntel
      ];
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Themes
  # this is crashing calibre
  # programs.qt5ct.enable = true;

  # Users
  users.users = {
    ${username} = {
      extraGroups = [
        "adbusers"
      ]; 
      description = "Lucas Eduardo";
    };
  };

  # ADB
  programs.adb.enable = true;
  services.udev.packages = with pkgs; [
    gnome3.gnome-settings-daemon
    android-udev-rules
  ];

  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };

  # não deixar explodir
  nix.maxJobs = 3;
  # kernel
  boot.kernelPackages = pkgs.linuxPackages_5_14;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

}
