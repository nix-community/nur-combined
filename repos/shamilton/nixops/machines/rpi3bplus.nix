{ hostName, systemStateVersion }:
{ pkgs, lib, ... }:
let
  localShamilton = import /home/scott/GIT/nur-packages/default.nix {};
in
{
  # disabledModules = [ "services/networking/create_ap.nix" ];
  imports = [
    # localShamilton.modules.autognirehtet
    # localShamilton.modules.rpi-fan
    <home-manager/nixos>
    ./cachix.nix
    # ./create_ap.nix
  ];

  nixpkgs.localSystem = {
    system = "aarch64-linux";
    config = "aarch64-unknown-linux-gnu";
  };

  nixpkgs.overlays = [
    (self: super: {
      firmwareLinuxNonfree = super.firmwareLinuxNonfree.overrideAttrs (old: {
        version = "2020-12-18";
        src = pkgs.fetchgit {
          url = "https://git.kernel.org/pub/scm/linux/kernel/git/firmwarha256";
          rev = "b79d2396bc630bfd9b4058459d3e82d7c3428599";
          sha256 = "1rb5b3fzxk5bi6kfqp76q1qszivi0v1kdz1cwj2llp5sd9ns03b5";
        };
        outputHash = "1p7vn2hfwca6w69jhw5zq70w44ji8mdnibm1z959aalax6ndy146";
      });
    })
  ];

  # Boot
  boot.loader = {
    grub.enable = false;
    timeout = 1;
    raspberryPi = {
      enable = true;
      version = 3;
      uboot.enable = true;
    };
  };
  boot.initrd.includeDefaultModules = false;

  # Kernel configuration
  boot.kernelPackages = pkgs.linuxPackages_rpi3;
  boot.kernelParams = ["cma=32M"];

  # Enable additional firmware (such as Wi-Fi drivers).
  hardware.enableRedistributableFirmware = true;

  # Filesystems
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };
  swapDevices = [ { device = "/swapfile"; size = 1024; } ];

  # Networking (see official manual or `/config/sd-image.nix` in this repo for other options)
  networking.hostName = hostName; # unleash your creativity!

  nix = {
    extraOptions = ''
     experimental-features = nix-command
    '';
  };

  # Packages
  environment.systemPackages = with pkgs; [
    # customize as needed!
    vim htop screen git file tree ripgrep
    libraspberrypi
  ];

  # Users
  # === IMPORTANT ===
  # Change `yourName` here with the name you'd like for your user!
  users.users = {
    scott = {
      isNormalUser = true;
      # Don't forget to change the home directory too.
      home = "/home/scott";
      # This allows this user to use `sudo`.
      extraGroups = [ "wheel" ];
      # SSH authorized keys for this user.
    };
  };
  home-manager.users.scott = import ./home.nix;
  # services.autognirehtet.enable = true;

  networking.resolvconf = {
    enable = true;
  };

  # Miscellaneous
  time.timeZone = "Europe/Paris"; # you probably want to change this -- otherwise, ciao!
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 817 ];
    allowedUDPPorts = [ 817 ];
  };
  services.openssh = {
    enable = true;
    passwordAuthentication = true;
    permitRootLogin = "yes";
    ports = [ 817 ];
    forwardX11 = true;
  };

  # WARNING: if you remove this, then you need to assign a password to your user, otherwise
  # `sudo` won't work. You can do that either by using `passwd` after the first rebuild or
  # by setting an hashed password in the `users.users.yourName` block as `initialHashedPassword`.
  security.sudo.wheelNeedsPassword = false;

  # Nix
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";
  boot.cleanTmpDir = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = systemStateVersion;
}
