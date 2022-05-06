{ config, lib, pkgs, ... }:

{
  users.extraGroups.vboxusers.members = [ "bjorn" ];
  virtualisation.virtualbox = {
    host.enable = true;
    host.enableExtensionPack = true;
  };
}
