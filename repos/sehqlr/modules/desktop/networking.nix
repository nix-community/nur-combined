{ config, pkgs, ... }: {
    networking.networkmanager.enable = true;
    users.users.sam.extraGroups = [ "networkmanager" ];
}
