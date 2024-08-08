{ lib, pkgs, ... }:
{
  home = {
    packages =
      with pkgs;
      [ gnome.dconf-editor ]
      ++ (with pkgs.gnomeExtensions; [
        customize-ibus
        enhanced-osk
      ]);
    # HACK: https://github.com/cass00/enhanced-osk-gnome-ext/blob/1921f4cae77bb0694766cfc22a1625e792b24db1/src/extension.js#L476-L477
    sessionVariables.JHBUILD_PREFIX = "${pkgs.gnome.gnome-shell}";
  };

  xdg.configFile.gnome-initial-setup-done.text = "yes";

  gtk = {
    enable = true;
    theme = {
      package = pkgs.adw-gtk3;
      name = "adw-gtk3";
    };
  };

  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [
        "enhancedosk@cass00.github.io"
        "customize-ibus@hollowman.ml"
      ];
      favorite-apps = [
        "firefox.desktop"
        "thunderbird.desktop"
        "org.gnome.Nautilus.desktop"
        "org.gnome.Calculator.desktop"
        "gnome-system-monitor.desktop"
        "org.gnome.Console.desktop"
      ];
    };
    "org/gnome/desktop/interface" = {
      enable-hot-corners = false;
      show-battery-percentage = true;
    };
    "org/gnome/desktop/input-sources" = {
      sources = [
        (lib.hm.gvariant.mkTuple [
          "ibus"
          "mozc-jp"
        ])
      ];
      xkb-options = [ "caps:ctrl_modifier" ]; # caps lock as ctrl
    };
    "org/gnome/desktop/peripherals/mouse" = {
      natural-scroll = true;
    };
    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
    };
    "org/gnome/desktop/wm/preferences" = {
      visual-bell = true;
      visual-bell-type = "frame-flash";
    };
    "org/gnome/desktop/a11y/applications" = {
      screen-keyboard-enable = true;
    };
    "org/gnome/mutter" = {
      dynamic-workspaces = true;
      edge-tiling = true;
    };
    "org/gnome/nautilus/list-view".use-tree-view = true;
    "org/gnome/nautilus/preferences" = {
      show-create-link = true;
      show-delete-permanently = true;
    };
    "org/gnome/gnome-system-monitor" = {
      show-dependencies = true;
      show-whose-processes = "all";
    };
    "org/gtk/setttings/file-chooser" = {
      show-hidden = true;
    };
    "org/gtk/gtk4/settings/file-chooser" = {
      show-hidden = true;
    };
  };
}
