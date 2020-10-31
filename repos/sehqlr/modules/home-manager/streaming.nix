{ config, lib, pkgs, ... }: {
    home.packages = with pkgs; [ chatterino2 ];
    programs.obs-studio = {
        enable = true;
        plugins = [
            pkgs.obs-wlrobs
        ];
    };
}
