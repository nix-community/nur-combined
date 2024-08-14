{ config, lib, pkgs, unstable, ... }:

{

  #fonts.enableDefaultFonts = mkDefault true;
  hardware.opengl.enable = true;

  programs = {
    dconf.enable = true;
    xwayland.enable = true;
  };

  security.polkit.enable = true;

  services.displayManager.sessionPackages = [ unstable.hyprland ];

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      unstable.xdg-desktop-portal-hyprland
      #pkgs.xdg-desktop-portal-gtk
    ];
  };


  # Hint Electon apps to use wayland
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  environment.systemPackages = with pkgs; [
    unstable.waybar
    unstable.hyprland
    unstable.swww # for wallpapers
    #xdg-desktop-portal-gtk
    unstable.xdg-desktop-portal-hyprland
    xwayland


  ];
}


