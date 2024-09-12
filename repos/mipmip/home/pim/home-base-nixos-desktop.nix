{ config, pkgs, ... }:

{

  fonts.fontconfig.enable = true;
  home.packages = [
    (pkgs.nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
  ];

  imports = [

    ./home-base-all.nix

    ./files-linux

    ./conf-desktop-linux/firefox.nix
    ./conf-desktop-linux/obs.nix
    ./conf-desktop-linux/xdg.nix
    ./conf-gnome
  ];

}
