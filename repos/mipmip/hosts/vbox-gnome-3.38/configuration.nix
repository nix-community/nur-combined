{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../shared-configuration.nix
      ../../modules/base-minimal.nix
      ../../modules/common.nix
      ../../modules/common-pkg.nix
      ../../modules/st.nix
      ../../modules/nixos-utils.nix
      ../../modules/workstation.nix
    ];

    services.xserver.displayManager.sessionCommands = "${pkgs.xorg.xmodmap}/bin/xmodmap ${myCustomLayout}";

    networking.hostName = "vbox-gnome-338";

    networking.networkmanager.enable = true;
    networking.useDHCP = false;
    networking.interfaces.wlp0s20u2.useDHCP = true;

    services.openssh.enable = true;
    services.virtualbox.enable = true;

    system.stateVersion = "20.09"; # Did you read the comment?
  }
