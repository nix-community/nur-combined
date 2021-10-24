{ config, lib, pkgs, ... }:

{

  virtualisation.virtualbox.host.enable = true;
#  virtualisation.virtualbox.guest.enable = true;
#  nixpkgs.config.virtualbox.enableExtensionPack = true;

  users.extraGroups.vboxusers.members = [ "pim" ];

#  environment.systemPackages = with pkgs; [
#    virtualbox # only on baremetal
#  ];

}

