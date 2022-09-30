# Working configuration for a RASPBERRY Pi 4 Model B
# used image: 
#  - https://hydra.nixos.org/build/134720986/download/1/nixos-sd-image-21.03pre262561.581232454fd-aarch64-linux.img.zst
#    from https://hydra.nixos.org/build/134720986, sha256sum: 2f756bc08a5f1e286a82ea4c9a50892f2aa9fd1688be37a85d4e36776569763e
# see: https://nixos.wiki/wiki/NixOS_on_ARM/Raspberry_Pi_4


{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_rpi4;

  # ttyAMA0 is the serial console broken out to the GPIO
  boot.kernelParams = [
    "8250.nr_uarts=1" # may be required only when using u-boot
    "console=ttyAMA0,115200"
    "console=tty1"
  ];

  # Delete the old one in ./hardware-configuration.nix
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  # Required for the Wireless firmware
  hardware.enableRedistributableFirmware = true;

  # RASPBERRY PI 4 B GPU Settings
  # without GPU:
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    videoDrivers = [ "fbdev" ];
  };
  # GPU enabled (doesn't seem to work as is):
  #hardware.opengl = {
  #  enable = true;
  #  setLdLibraryPath = true;
  #  package = pkgs.mesa_drivers;
  #};
  #hardware.deviceTree = {
  #  kernelPackage = pkgs.linux_rpi4;
  #  overlays = [ "${pkgs.device-tree_rpi.overlays}/vc4-fkms-v3d.dtbo" ];
  #};
  #services.xserver = {
  #  enable = true;
  #  displayManager.lightdm.enable = true;
  #  videoDrivers = [ "modesetting" ];
  #};
  #boot.loader.raspberryPi.firmwareConfig = ''
  #  gpu_mem=192
  #'';
  # END RASPBERRY PI 4 B GPU Settings

  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };

  networking.hostName = "nixos"; # Define your hostname.
  time.timeZone = "Europe/Vienna";
  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;
  networking.interfaces.wlan0.useDHCP = false;
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
  '';
  programs.slock.enable = true;
  services.clipmenu.enable = true;
  services.xserver.exportConfiguration = true;
  services.gvfs.enable = true;
  services.xserver.displayManager = { 
    defaultSession = "none+instantwm";
    gdm.enable = false;
    sddm.enable = false;
  };  
  services.xserver.desktopManager = { 
    gnome.enable = false;
    plasma5.enable = false;
    xterm.enable = false;
  };  
  services.xserver.windowManager = { 
    session = pkgs.lib.singleton {
      name = "instantwm";
      start = ''
        startinstantos &
        waitPID=$!
      ''; 
    };  
  };
  fonts.fonts = with pkgs; [
    cantarell-fonts
    fira-code
    fira-code-symbols
    dina-font
    joypixels
    (nerdfonts.override { fonts = [ "FiraCode" "FiraMono" ]; })
  ]; 
  nixpkgs.config.joypixels.acceptLicense = true;
  nixpkgs.config.allowUnfree = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jan = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "audio" "networkmanager" "wireshark" "dialout" "plugdev" "adm" "disk" "video" "docker" ];
    #openssh.authorizedKeys.keys = ssh_pkeys;
    hashedPassword = "$6$Xe3WN...";  # generate with mkpasswd -m sha-512
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3..."            # paste your PUBLIC ssh keys here
      "ssh-ed25519 AAAAC3..."        #...to give access
    ];
  };

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    nur.repos.instantos.instantnix
    screen tree file
    wget curl w3m inetutils dnsutils nmap openssl mkpasswd
    flameshot
    gitAndTools.git git-lfs
    nix-prefetch-scripts nix-update nixpkgs-review cachix
    vim
    papirus-icon-theme arc-theme
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  system.stateVersion = "21.03";
}
