{ lib, ... }:

let
  mkTuple = lib.hm.gvariant.mkTuple;
in
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

    "org/gnome/desktop/input-sources" = {
      mru-sources = [ (mkTuple [ "xkb" "us" ]) ];
      per-window = false;
      sources = [ (mkTuple [ "xkb" "us" ]) ];
      xkb-options = [ "grp:alt_shift_toggle" "lv3:ralt_switch" "compose:ralt" "caps:none"];
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

    "org/gnome/desktop/wm/keybindings" = {
      close                        = [ "<Super>q" ];
      cycle-windows-backward       = [ "<Shift><Super>Escape" ];
      maximize                     = [ "<Super>Up" ];
      toggle-maximized             = [ "<Super>t" ];
      minimize                     = [ "<Alt>F4" ];
      move-to-workspace-1          = [];
      move-to-workspace-2          = [];
      move-to-workspace-3          = [];
      move-to-workspace-4          = [];
      show-desktop                 = [ "F12" ];
      switch-input-source          = [];
      switch-input-source-backward = [];
      switch-to-workspace-1        = [];
      switch-to-workspace-2        = [];
      switch-to-workspace-3        = [];
      switch-to-workspace-4        = [];
      switch-to-workspace-last     = [];
      toggle-fullscreen            = [ "<Super>f" ];
      cycle-windows                = [ "<Super>Escape" ];
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

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8/"
      ];
      screensaver = [];
      search = [ "<Super>/" ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>Return";
      command = "env st";
      name = "st";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      binding = "<Shift><Super>F";
      command = "nautilus";
      name = "filemanager";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
      binding = "<Shift><Super>exclam";
      command = "appimage-run /home/pim/cPassingTrain/trajno/dist_electron/Trajno-latest.AppImage";
      name = "Tempo";
    };


    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
      binding = "<Shift><Super>dollar";
      command = "gnome-screenshot -a";
      name = "screenshot";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" = {
      binding = "<Shift><Super>B";
      command = "firefox";
      name = "firefox";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5" = {
      binding = "<Shift><Super>at";
      command = "keepassxc";
      name = "keepassxc";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6" = {
      binding = "<Shift><Super>percent";
      command = "gnome-screenshot -i";
      name = "screenshot-interactive";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7" = {
      binding = "<Super>s";
      command = "/home/pim/cGnome/gnome-hotkeys.cr/bin/myhotkeys /home/pim/.hotkeys-custom.json";
      name = "myhotkeys";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8" = {
      binding = "F11";
      command = "bash -c 'pkill nemo-desktop || nemo-desktop'";
      name = "toggle-nemo-desktop";
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

    "org/gnome/mutter/keybindings" = {
      toggle-tiled-left = [ "<Primary><Shift>Left" ];
      toggle-tiled-right = [ "<Primary><Shift>Right" ];
    };

    # FIX OVERLAP WITH SUPER ESCAPE CYCLE WINDOWS
    "org/gnome/mutter/wayland/keybindings" = {
      restore-shortcuts=[""];
    };

  };
}
