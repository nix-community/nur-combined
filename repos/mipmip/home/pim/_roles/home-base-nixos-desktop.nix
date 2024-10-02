{ config, pkgs, ... }:

{

  fonts.fontconfig.enable = true;
  home.packages = [
    (pkgs.nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
  ];

  imports = [

    ../files-gimp

    ../conf-cli/alacritty.nix
    ../conf-cli/terminals.nix

    ../conf-desktop-linux/firefox.nix
    ../conf-desktop-linux/obs.nix
    ../conf-desktop-linux/xdg.nix

    ../conf-gnome

  ];

}
