{ ... }:

# Custom Gnome keyboard keys are listed here:
# https://discussion.fedoraproject.org/t/custom-keyboard-layout-in-gnome-wayland/68923
{
  dconf.settings = {

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

    "org/gnome/mutter/keybindings" = {
      toggle-tiled-left = [ "<Primary><Shift>Left" ];
      toggle-tiled-right = [ "<Primary><Shift>Right" ];
    };

    # FIX OVERLAP WITH SUPER ESCAPE CYCLE WINDOWS
    "org/gnome/mutter/wayland/keybindings" = {
      restore-shortcuts=[""];
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
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom9/"
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

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom9" = {
      binding = "<Shift><Super>asciicircum";
      command = "slack";
      name = "slack";
    };
  };
}
