{ config, pkgs, ... }:

{
  imports = [
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
    ../../modules/desktop-fonts.nix
    ../../modules/desktop-gnome.nix
    ../../modules/desktop-st.nix
    ../../modules/desktop-dev.nix
    ../../modules/desktop-video.nix
    ../../modules/desktop-audio.nix
    ../../modules/desktop-virtualbox.nix
    ../../modules/desktop-security.nix

    ../../modules/dev-go.nix
    ../../modules/dev-crystal.nix
    ../../modules/dev-technative.nix

    ../../modules/explore-pkg.nix

    ../../modules/hardware-kbd-keychron.nix
    ../../modules/hardware-krd_disable-caps.nix
    ../../modules/hardware-printers.nix
    ../../modules/network-wireguard-tracklib.nix
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

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  powerManagement.cpuFreqGovernor = "schedutil";

  networking.hostName = "billquick";

  networking.wireless.enable = false;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;
  networking.useDHCP = false;

  system.stateVersion = "22.05";
}
