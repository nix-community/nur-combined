{ pkgs, ... }:
{
  my.home = {
    # Bluetooth GUI & media keys
    bluetooth.enable = true;
    # Image viewver
    feh.enable = true;
    # Firefo profile and extensions
    firefox.enable = true;
    # Blue light filter
    gammastep.enable = true;
    # Use a small popup to enter passwords
    gpg.pinentry = "gtk2";
    # GTK theme configuration
    gtk.enable = true;
    # Machine specific packages
    packages.additionalPackages = with pkgs; [
      jellyfin-media-player # Wraps the webui and mpv together
      pavucontrol # Audio mixer GUI
      quasselClient # IRC client
      transgui # Transmission remote
    ];
    # Network-Manager applet
    nm-applet.enable = true;
    # Termite terminal
    terminal.program = "termite";
    # i3 settings
    wm.windowManager = "i3";
    # Keyboard settings
    x.enable = true;
    # Zathura document viewer
    zathura.enable = true;
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # Enable i3
  services.xserver.windowManager.i3.enable = true;
  # Nice wallpaper
  services.xserver.displayManager.lightdm.background =
    let
      wallpapers = "${pkgs.plasma-workspace-wallpapers}/share/wallpapers";
    in
    "${wallpapers}/summer_1am/contents/images/2560x1600.jpg";

  services.dbus.packages = with pkgs; [
    # Allow setting GTK configuration using home-manager
    gnome3.dconf
  ];
}
