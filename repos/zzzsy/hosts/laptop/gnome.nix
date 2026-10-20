{ pkgs, ... }:

{
  config = {
    services.xserver = {
      enable = false;
      excludePackages = [ pkgs.xterm ];
    };
    services.displayManager = {
      defaultSession = "niri";
      gdm.enable = false;
      ly.enable = true;
      ly.x11Support = false;
    };
    programs.kdeconnect = {
      enable = true;
      package = pkgs.valent;
    };

    xdg.terminal-exec = {
      enable = true;
      settings = {
        default = [ "kitty.desktop" ];
      };
    };

    programs.dconf.enable = true;
    environment.systemPackages = (
      with pkgs;
      [
        ffmpegthumbnailer
        amberol # music
        loupe # image
        gnome-text-editor
        # epiphany
        papers
        nautilus # file
        file-roller # archive
        # refine
        gnome-disk-utility
        seahorse
        # gnome-calendar
        # dconf-editor
        poop
        comma
        android-tools
      ]
    );
  };
}
