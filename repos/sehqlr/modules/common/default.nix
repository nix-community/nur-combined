{ config, lib, pkgs, ... }: {
    i18n.defaultLocale = "en_US.UTF-8";
    nix.autoOptimiseStore = true;
    nix.gc.automatic = true;

    services.ipfs = {
        enable = true;
        enableGC = true;
    };

    system.autoUpgrade.enable = true;
    system.copySystemConfiguration = true;
}
