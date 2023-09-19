{ lib, ... }:

{
  dconf.settings = {

    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///home/pim/Nextcloud/Wallpapers/johannes-plenio-6lDhQ7fCtYc-unsplash.jpg";
      picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-d.svg";
      primary-color = "#000000000000";
      secondary-color = "#000000000000";
    };

    "org/gnome/desktop/calendar" = {
      show-weekdate = true;
    };

    "org/gnome/desktop/interface" = {
      clock-format = "24h";
      clock-show-weekday = false;
      cursor-theme = "Adwaita";
      enable-animations = true;
      enable-hot-corners = false;
      font-antialiasing = "grayscale";
      font-hinting = "none";
      font-name = "Liberation Sans 10";
      gtk-enable-primary-paste = false;
      gtk-im-module = "gtk-im-context-simple";
      gtk-theme = "Adwaita";
      icon-theme = "Adwaita";
      text-scaling-factor = 1.0;
      toolbar-style = "text";
    };


    "org/gnome/desktop/wm/preferences" = {
      action-double-click-titlebar = "minimize";
      auto-raise                   = true;
      button-layout                = "close:appmenu";
      focus-mode                   = "click";
      num-workspaces               = 3;
      resize-with-right-button     = false;
      theme                        = "Default";
      workspace-names              = [ "1" "2" "3" "4" ];
    };

    "org/gnome/settings-daemon/plugins/xsettings" = {
      overrides = "{'Gtk/EnablePrimaryPaste': <0>, 'Gtk/DecorationLayout': <'close,minimize,maximize:menu'>, 'Gtk/ShellShowsAppMenu': <0>, 'Gtk/DialogsUseHeader': <0>}";
    };

    "org/gnome/mutter" = {
      center-new-windows = true;
      dynamic-workspaces = false;
      overlay-key = "Super_R";
      workspaces-only-on-primary = true;
    };
  };
}
