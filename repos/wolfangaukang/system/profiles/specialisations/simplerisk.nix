{ pkgs, lib, ... }:

let
  inherit (lib) mkForce;

in {
  profile.virtualization = {
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
    vmware.enable = true;
  };
  home-manager.users.bjorn.defaultajAgordoj.work.simplerisk.enable = true;
}
