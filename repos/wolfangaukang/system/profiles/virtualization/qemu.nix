{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    virt-manager
  ];
  users.extraGroups.libvirtd.members = [ "bjorn" ];
  virtualisation.libvirtd = {
    enable = true;
  };
}
