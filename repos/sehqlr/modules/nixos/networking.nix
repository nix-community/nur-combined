{ config, pkgs, ... }: {
    networking = {
        networkmanager.enable = true;
        useDHCP = false;
    };
    users.users.sam.extraGroups = [ "networkmanager" ];
}
