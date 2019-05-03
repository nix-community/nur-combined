{ config, pkgs, ... }:

{
  services.xserver = {
    # Enable the X11 windowing system.
    enable = true;

    # Keyboard options
    layout = "us";
    xkbOptions = "caps:escape,compose:ralt";
    autoRepeatDelay = 300;
    autoRepeatInterval = 30;

    # Enable the SDDM login manager.
    displayManager.lightdm = {
      enable = true;
      # autoLogin = {
      #   enable = true;
      #   user = "casper";
      # };
    };

    # bspwm window manager.
    windowManager = {
      # default = "bspwm";
      bspwm = {
        enable = true;
        configFile = ../../dotfiles/bspwmrc;
        sxhkd.configFile = ../../dotfiles/sxhkdrc;
      };
    };
  };

  environment.etc = {
    "xdg/gtk-2.0/gtkrc" = {
      mode = "444";
      text = ''
        gtk-theme-name = "Arc-Dark"
        gtk-icon-theme-name = "Paper"
      '';
    };
    "xdg/gtk-3.0/settings.ini" = {
      mode = "444";
      text = ''
        [Settings]
        gtk-theme-name = Arc-Dark
        gtk-icon-theme-name = Paper
      '';
    };
    "xdg/mimeapps.list" = {
      mode = "444";
      text = builtins.readFile ../../dotfiles/mimeapps.list;
    };
  };

  environment.extraInit = ''
    export XDG_CONFIG_DIRS="/etc/xdg:$XDG_CONFIG_DIRS"
    export RUST_BACKTRACE=1
    export XDG_DATA_DIRS=$XDG_DATA_DIRS:${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/gsettings-desktop-schemas-${pkgs.gsettings-desktop-schemas.version}
  '';

  fonts = {
    fonts = with pkgs; [
      dejavu_fonts
      nerdfonts ubuntu_font_family
      noto-fonts-cjk fira-code
      fantasque-sans-mono
    ];
    fontconfig = {
      #hinting.enable = false;
      subpixel.rgba = "none";
      subpixel.lcdfilter = "none";
    };
  };
}
