{ config, lib, pkgs, ... }: {
    services.ipfs = {
        enable = true;
        enableGC = true;
    };
}
