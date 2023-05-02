# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, inputs, system, pkgs, unstable, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      ../../modules/base-common.nix
      ../../modules/base-docker.nix
      ../../modules/base-git.nix
      ../../modules/base-hardware.nix
      ../../modules/base-infrastructure.nix
      ../../modules/base-modern-unix.nix
      ../../modules/base-tex.nix
      ../../modules/base-tmux.nix
      ../../modules/base-vim.nix

      ../../modules/desktop-chrome.nix
      ../../modules/desktop-communication.nix
      ../../modules/desktop-dtp.nix
      ../../modules/desktop-firefox.nix
      ../../modules/desktop-dev.nix
      ../../modules/desktop-fonts.nix
      ../../modules/desktop-gnome.nix
      ../../modules/desktop-st.nix
      ../../modules/desktop-video.nix
      ../../modules/desktop-virtualbox.nix
      ../../modules/desktop-security.nix

      ../../modules/dev-crystal.nix
      ../../modules/dev-go.nix
      ../../modules/dev-technative.nix

      ../../modules/explore-pkg.nix

      ../../modules/hardware-kbd-keychron.nix
      ../../modules/hardware-krd_disable-caps.nix
      ../../modules/hardware-printers.nix

      ../../modules/nix-comma.nix
      ../../modules/nix-common.nix
      ../../modules/nix-desktop.nix
      ../../modules/nix-home-manager-global.nix
      ../../modules/nix-utils.nix
      ../../modules/nur-my-pkgs.nix
    ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
            experimental-features = nix-command flakes
    '';
  };
  #services.xserver.xkbOptions = "caps:none,terminate:ctrl_alt_bks,altwin:swap_alt_win";

  networking.hosts = {
    "127.0.0.1" = [
      "ojs"
      "localhost"
    ];
    "161.97.169.230" = [
      "invokeai.amy.node.snel.city"
    ];
  };



  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.kernelPackages = unstable.linuxPackages_latest;
  networking.hostName = "lego1";

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-57e3184e-15a9-4b84-9de7-ccf0fdb877eb".device = "/dev/disk/by-uuid/57e3184e-15a9-4b84-9de7-ccf0fdb877eb";
  boot.initrd.luks.devices."luks-57e3184e-15a9-4b84-9de7-ccf0fdb877eb".keyFile = "/crypto_keyfile.bin";

  # Enable networking
  networking.networkmanager.enable = true;


  networking.firewall.enable = false;

  system.stateVersion = "22.11"; # Did you read the comment?

}
