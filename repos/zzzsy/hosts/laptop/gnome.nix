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
    services.gnome = {
      gnome-keyring.enable = true;
    };
    programs.kdeconnect = {
      enable = true;
      package = pkgs.valent;
    };
    programs.gtklock = {
      enable = true;
      config = {
        main = {
          follow-focus = true;
          start-hidden = true;
        };
        powerbar.show-labels = true;
      };
      style = ''
        #playerctl-revealer {
          padding-bottom: 100px
        }
        #powerbar-revealer {
          padding-bottom: 10px
        }
        window{background-image:url("/home/zzzsy/.local/share/background");background-size:cover}
        #playerctl-revealer{padding-bottom:100px}
        #powerbar-revealer{padding-bottom:10px}
      '';
      modules = with pkgs; [
        gtklock-playerctl-module
        gtklock-powerbar-module
      ];
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
