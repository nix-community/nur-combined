{ config, pkgs, ... }:

{
  services.xserver = {
    # Enable the X11 windowing system.
    enable = true;

    # Keyboard options
    xkb.layout = "us";
    xkb.options = "caps:escape,compose:ralt";
    autoRepeatDelay = 300;
    autoRepeatInterval = 30;

    # Enable the SDDM login manager.
    displayManager.lightdm = {
      enable = true;
    };

    # bspwm window manager.
    windowManager = {
      # default = "bspwm";
      bspwm = {
        enable = true;
        configFile = ../../dotfiles/bin/bspwmrc;
        sxhkd.configFile = ../../dotfiles/sxhkdrc;
      };
    };
  };

  environment.variables = {
    GTK_THEME = "Nordic";
    GTK_ICON_THEME = "Paper";
  };

  environment.etc = {
    "xdg/gtk-2.0/gtkrc" = {
      mode = "444";
      text = ''
        gtk-theme-name = "${config.environment.variables.GTK_THEME}"
        gtk-icon-theme-name = "${config.environment.variables.GTK_ICON_THEME}"
      '';
    };
    "xdg/gtk-3.0/settings.ini" = {
      mode = "444";
      text = ''
        [Settings]
        gtk-theme-name = ${config.environment.variables.GTK_THEME}
        gtk-icon-theme-name = ${config.environment.variables.GTK_ICON_THEME}
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
    packages = with pkgs; [
      dejavu_fonts
      ubuntu_font_family
      noto-fonts-cjk-sans fira-code
      # Broken: EULA url returns 503.
      # corefonts
    ];
    fontconfig = {
      subpixel.rgba = "none";
      subpixel.lcdfilter = "none";
    };
  };
}
