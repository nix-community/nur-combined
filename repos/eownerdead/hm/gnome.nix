{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.eownerdead.gnome;
in
{
  imports = [ ./firefox.nix ];

  options.eownerdead.gnome.enable = lib.mkEnableOption "Enable gnome";

  config = lib.mkIf cfg.enable {
    eownerdead.firefox.enable = true;
    home = {
      preferXdgDirectories = true;
      packages =
        with pkgs;
        [
          dialect
          resources
          iotas
          gnome-graphs
          dconf-editor
          d-spy
          bustle
          packet
        ]
        ++ (with gnomeExtensions; [
          customize-ibus
          gjs-osk
          screen-rotate
          # enhanced-osk
        ]);
      # HACK: https://github.com/cass00/enhanced-osk-gnome-ext/blob/1921f4cae77bb0694766cfc22a1625e792b24db1/src/extension.js#L476-L477
      sessionVariables.JHBUILD_PREFIX = "${pkgs.gnome-shell}";
    };

    xdg = {
      mimeApps = {
        enable = true;
        defaultApplications = {
          "application/pdf" = [ "org.gnome.Evince.desktop" ];
        };
      };
      configFile.gnome-initial-setup-done.text = "yes";
    };

    gtk = {
      enable = true;
      theme = {
        package = pkgs.adw-gtk3;
        name = "adw-gtk3";
      };
    };

    services = {
      gpg-agent.pinentry.package = pkgs.pinentry-gnome3;
      easyeffects.enable = true;
    };

    dconf.settings = {
      "org/gnome/shell" = {
        enabled-extensions = [
          "enhancedosk@cass00.github.io"
          "customize-ibus@hollowman.ml"
          "screen-rotate@shyzus.github.io"
          "gjsosk@vishram1123.com"
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
      "org/gnome/shell/extensions/gjsosk" = {
        landscape-height-percent = 40;
        landscape-width-percent = 70;
        layout-landscape = 5;
        layout-portrait = 5;
        play-sound = false;
        font-size-px = 20;
        font-bold = true;
        round-key-cornders = true;
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
      "org/gnome/desktop/app-folders".folder-children = [
        "Office"
        "Systems"
        "Utilities"
      ];
      "org/gnome/desktop/app-folders/folders/Office" = {
        name = "Office";
        apps = [
          "startcenter.desktop"
          "base.desktop"
          "calc.desktop"
          "draw.desktop"
          "impress.desktop"
          "math.desktop"
          "writer.desktop"
          "wps-office-prometheus.desktop"
          "wps-office-pdf.desktop"
          "wps-office-wpp.desktop"
          "wps-office-et.desktop"
          "wps-office-wps.desktop"
        ];
      };
      "org/gnome/desktop/app-folders/folders/System" = {
        name = "System";
        apps = [
          "org.gnome.baobab.desktop"
          "org.gnome.DiskUtility.desktop"
          "org.gnome.Logs.desktop"
          "org.gnome.SystemMonitor.desktop"
          "ca.desrt.dconf-editor.desktop"
          "org.gnome.Tour.desktop"
          "yelp.desktop"
          "org.gnome.dspy.desktop"
          "org.gnome.Settings.desktop"
          "org.gnome.Extensions.desktop"
          "cups.desktop"
          "nixos-manual.desktop"
        ];
      };
      "org/gnome/desktop/app-folders/folders/Utilities" = {
        name = "Utilities";
        apps = [
          "org.gnome.Connections.desktop"
          "org.gnome.Evince.desktop"
          "org.gnome.FileRoller.desktop"
          "org.gnome.font-viewer.desktop"
          "org.gnome.Loupe.desktop"
          "org.gnome.seahorse.Application.desktop"
          "simple-scan.desktop"
          "org.gnome.Characters.desktop"
        ];
      };
      "org/gnome/mutter" = {
        dynamic-workspaces = true;
        edge-tiling = true;
        experimental-features = [
          "scale-monitor-framebuffer"
          "xwayland-native-scaling"
        ];
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
      "org/gtk/settings/file-chooser" = {
        show-hidden = true;
      };
      "org/gtk/gtk4/settings/file-chooser" = {
        show-hidden = true;
      };
    };
  };
}
