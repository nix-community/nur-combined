{
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkForce;

in
{
  imports = [ ./cinnamon.nix ];
  profile = {
    predicates.unfreePackages = [
      "Oracle_VirtualBox_Extension_Pack"
      "slack"
      "virtualbox-extpack"
      "vmware-workstation"
    ];
    specialisations.work.simplerisk.indicator = true;
    virtualization = {
      podman.enable = mkForce false;
      qemu.enable = mkForce false;
      docker = {
        enable = true;
        extraPkgs = with pkgs; [ docker-compose ];
        dockerGroupMembers = [ "bjorn" ];
      };
      virtualbox = {
        enable = true;
        enableExtensionPack = true;
        vboxusersGroupMembers = [ "bjorn" ];
      };
      # vmware.enable = true;
    };
  };
  services.qbittorrent.enable = mkForce false;
}
