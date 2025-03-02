{ pkgs, ... }:

{
  imports = [ ];
  config = {
    services.xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      excludePackages = [ pkgs.xterm ];
      desktopManager.xterm.enable = false;
    };
    services.gnome = {
      core-utilities.enable = false;
      gnome-online-accounts.enable = false;
      gnome-browser-connector.enable = true;
      localsearch.enable = false;
      tinysparql.enable = false;
    };
    environment.gnome.excludePackages = (
      with pkgs;
      [
        gnome-tour
        orca
      ]
    );
    programs.xwayland = {
      enable = true;
      package = pkgs.xwayland-satellite;
    };
    programs.niri.package = pkgs.niri-unstable;
    programs.niri.enable = true;

    programs.dconf.enable = true;
    # fix nautilus extensions deu to `core-utilities.enable = false`
    mods.gnome-fix.enable = true;
    environment.systemPackages = (
      with pkgs;
      [
        ffmpegthumbnailer
        amberol # music
        loupe # image
        gnome-text-editor
        epiphany
        #papers
        evince
        nautilus # file
        file-roller # archive
        gnome-tweaks
        gnome-disk-utility
        seahorse
        gnome-calendar
        dconf-editor

        # ghostty
      ]
    );
    #++ (with pkgs.gnome; [ ]);
  };
}
