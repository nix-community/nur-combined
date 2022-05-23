{ pkgs, ... }:
{
  my.home = {
    # Some amount of social life
    discord.enable = true;
    # Image viewver
    feh.enable = true;
    # Firefo profile and extensions
    firefox.enable = true;
    # Blue light filter
    gammastep.enable = true;
    # Use a small popup to enter passwords
    gpg.pinentry = "gtk2";
    # Machine specific packages
    packages.additionalPackages = with pkgs; [
      jellyfin-media-player # Wraps the webui and mpv together
      pavucontrol # Audio mixer GUI
      quasselClient # IRC client
      teams # Work requires it...
      transgui # Transmission remote
    ];
    # Minimal video player
    mpv.enable = true;
    # Network-Manager applet
    nm-applet.enable = true;
    # Termite terminal
    terminal.program = "termite";
    # Zathura document viewer
    zathura.enable = true;
  };
}
