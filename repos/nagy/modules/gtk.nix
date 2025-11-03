{ pkgs, ... }:

let
  format = pkgs.formats.ini { };
in
{

  environment.etc."xdg/gtk-3.0/settings.ini".source = format.generate "gtk3-settings.ini" {
    Settings = {
      gtk-enable-animations = false;
      gtk-im-module = "xim";
      gtk-overlay-scrolling = false;
      gtk-cursor-blink = false;
      gtk-button-images = 0;
      gtk-menu-images = 0;

      # This could also be set in fonts.nix with the fontconfig.defaultFonts.sansSerif option.
      # but it seems that the default is already taken from fontconfig.
      # gtk-font-name = "Iosevka Comfy";

      # Deactivating because C-w closing tab in firefox does not work
      # gtk-key-theme-name = "Emacs";
    };
  };
  # does not get picked up by gtk.
  # requires a symlink in the home directory
  # ln -s /etc/xdg/gtk-3.0/gtk.css ~/.config/gtk-3.0/
  environment.etc."xdg/gtk-3.0/gtk.css".text = ''
    scrollbar slider{
        /* Size of the slider */
        min-width: 10px;
        min-height: 10px;
        border-radius: 0px;
        /* Padding around the slider */
        border: 0px solid transparent;
    }

    /* This prevents a border on the scrollbars in Emacs */
    scrollbar trough, scrollbar slider {
        min-width: 10px;
        border: 0px;
    }
  '';

  environment.etc."xdg/gtk-4.0/settings.ini".source = format.generate "gtk4-settings.ini" {
    Settings = {
      gtk-enable-animations = false;
      gtk-im-module = "xim";
      gtk-overlay-scrolling = false;
      gtk-cursor-blink = false;
      gtk-button-images = 0;
      gtk-menu-images = 0;
    };
  };

  # Fix gdk/gtk for highdpi. otherwise icons are too small and webkitgtk is also skewed.
  environment.sessionVariables = {
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "0.5";
  };
}
