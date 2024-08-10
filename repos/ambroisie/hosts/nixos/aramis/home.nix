{ pkgs, ... }:
{
  my.home = {
    # Use graphical pinentry
    bitwarden.pinentry = pkgs.pinentry-gtk2;
    # Ebook library
    calibre.enable = true;
    # Some amount of social life
    discord.enable = true;
    # Image viewver
    feh.enable = true;
    # Firefo profile and extensions
    firefox.enable = true;
    # Blue light filter
    gammastep.enable = true;
    # Use a small popup to enter passwords
    gpg.pinentry = pkgs.pinentry-gtk2;
    # Machine specific packages
    packages.additionalPackages = with pkgs; [
      element-desktop # Matrix client
      jellyfin-media-player # Wraps the webui and mpv together
      pavucontrol # Audio mixer GUI
      transgui # Transmission remote
    ];
    # Minimal video player
    mpv.enable = true;
    # Network-Manager applet
    nm-applet.enable = true;
    # Terminal
    terminal.program = "alacritty";
    # Zathura document viewer
    zathura.enable = true;
  };
}
