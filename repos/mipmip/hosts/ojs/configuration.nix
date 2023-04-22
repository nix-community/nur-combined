{ config, inputs, system, pkgs, ... }:

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
    ../../modules/desktop-dev.nix
    ../../modules/desktop-fonts.nix
    ../../modules/desktop-gnome.nix
    ../../modules/desktop-st.nix
    ../../modules/desktop-video.nix
    ../../modules/desktop-audio.nix
    ../../modules/desktop-virtualbox.nix
    ../../modules/desktop-security.nix

    ../../modules/dev-crystal.nix
    ../../modules/dev-go.nix
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

  networking.hosts = {
    "127.0.0.1" = [
      "ojs"
      "localhost"
    ];
    "10.57.194.13" = [
      "jenkins.prod.ki.ecg.so"
    ];
    "161.97.169.230" = [
      "invokeai.amy.node.snel.city"
    ];
  };

  networking.hostName = "ojs";
  networking.wireless.enable = false;  # Enables wireless support via wpa_supplicant.

  systemd.services.NetworkManager-wait-online.enable = false;

  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --source 192.168.13.0/24 --dport 21:21 -j nixos-fw-accept
  '';

  services.vsftpd = {
    enable = true;
    writeEnable = true;
    localUsers = true;
    userlist = [ "pim" ];
    userlistEnable = true;
  };

  networking.networkmanager.enable = true;
  networking.useDHCP = false;
  networking.interfaces.enp10s0.useDHCP = true;
  networking.interfaces.enp9s0.useDHCP = true;
  networking.interfaces.wlp0s29f7u5.useDHCP = true;

  networking.interfaces.wlp13s0.wakeOnLan.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.extraModulePackages = [
    config.boot.kernelPackages.broadcom_sta
  ];

  system.stateVersion = "22.05";
}
