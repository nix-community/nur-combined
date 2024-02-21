{ config, inputs, system, pkgs, ... }:

{
  imports = [

    ./hardware-configuration.nix
    ../_roles/desktop.nix
    ../../modules/nix-samba.nix
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
  #networking.wireless.enable = false;  # Enables wireless support via wpa_supplicant.

  #systemd.services.NetworkManager-wait-online.enable = false;

  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --source 192.168.13.0/24 --dport 21:21 -j nixos-fw-accept
  '';
  networking.firewall.enable = false;

  virtualisation.waydroid.enable = true;

  services.vsftpd = {
    enable = true;
    writeEnable = true;
    localUsers = true;
    userlist = [ "pim" ];
    userlistEnable = true;
  };

  networking.networkmanager.enable = true;
  #networking.useDHCP = false;
  #networking.interfaces.enp10s0.useDHCP = true;
  #networking.interfaces.enp9s0.useDHCP = true;
  #networking.interfaces.wlp0s29f7u5.useDHCP = true;

  #networking.interfaces.wlp13s0.wakeOnLan.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;


  system.stateVersion = "22.05";
}
