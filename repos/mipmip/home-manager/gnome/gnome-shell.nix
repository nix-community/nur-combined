{ ... }:

{
  dconf.settings = {

    "org/gnome/shell" = {
      disable-user-extensions = false;

      favorite-apps = [
        "nemo.desktop"
        "org.gnome.Evolution.desktop"
        "firefox.desktop"
        "Alacritty.desktop"
        "virtualbox.desktop"
        "org.gnome.Calendar.desktop"
        "org.inkscape.Inkscape.desktop" ];
    };

    "org/gnome/shell/keybindings" = {
      switch-to-application-1 = [];
      switch-to-application-2 = [];
      switch-to-application-3 = [];
      switch-to-application-4 = [];
      switch-to-application-5 = [];
      switch-to-application-6 = [];
      switch-to-application-7 = [];
      switch-to-application-8 = [];
      switch-to-application-9 = [];
      toggle-application-view = [ "" ];
      toggle-overview = [ "" ];
    };
  };
}
