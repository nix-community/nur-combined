{ config, pkgs, lib, ... }:

{
  imports = [
    ../common/colemak.nix
    ../common/mako.nix
    ../common/udiskie.nix
    ../common/waybar.nix
  ];
  
  home = {
    file.".config/wayfire.ini".source = ../../../../config/wayfire/wayfire.ini;
  };

  gtk = {
    enable = true;
    #font = {
    #  name = "Fira Sans 8";
    #};
    gtk2.extraConfig = "gtk-application-prefer-dark-theme=1";
    gtk3 = {
      extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };
  };
}
