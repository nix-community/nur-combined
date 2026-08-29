{ pkgs, ... }:
{
  my.home = {
    # Use graphical pinentry
    bitwarden.pinentry = pkgs.pinentry-qt;
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
    gpg.pinentry = pkgs.pinentry-qt;
    # Machine specific packages
    packages.additionalPackages = with pkgs; [
      element-desktop # Matrix client
      pavucontrol # Audio mixer GUI
    ];
    # Minimal video player
    mpv.enable = true;
    # Network-Manager applet
    nm-applet.enable = true;
    # Terminal
    terminal.program = "alacritty";
    # Transmission remote
    trgui.enable = true;
    # Zathura document viewer
    zathura.enable = true;
  };
}
