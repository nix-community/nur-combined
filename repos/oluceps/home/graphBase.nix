{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
{
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.graphite-cursors;
    name = "graphite-light-nord";
    size = 22;
  };

  programs = {
    vscode = {
      enable = true;
      package = pkgs.vscode.fhsWithPackages (
        ps: with ps; [
          rustup
          zlib
        ]
      );
    };

    pandoc.enable = true;

    obs-studio = {
      enable = true;
      plugins = with pkgs; [ obs-studio-plugins.wlrobs ];
    };
    # swww.enable = true;
  };

  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.fluent-icon-theme;
      name = "Fluent";
    };
    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      {
        "tg" = [ "org.telegram.desktop.desktop" ];

        "application/pdf" = [ "sioyek.desktop" ];
        "ppt/pptx" = [ "wps-office-wpp.desktop" ];
        "doc/docx" = [ "wps-office-wps.desktop" ];
        "xls/xlsx" = [ "wps-office-et.desktop" ];
      }
      // lib.genAttrs
        [
          "x-scheme-handler/unknown"
          "x-scheme-handler/about"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
          "x-scheme-handler/mailto"
          "text/html"
        ]
        # (_: "brave-browser.desktop")
        (_: "firefox.desktop")
      // lib.genAttrs [
        "image/gif"
        "image/webp"
        "image/png"
        "image/jpeg"
      ] (_: "org.gnome.Loupe.desktop")
      // lib.genAttrs [
        "inode/directory"
        "inode/mount-point"
      ] (_: "org.gnome.Nautilus");
  };

  services = {

    swayidle = {
      enable = false;
      systemdTarget = "sway-session.target";
      timeouts = [
        {
          timeout = 900;
          command = "${pkgs.swaylock}/bin/swaylock";
        }
        {
          timeout = 905;
          command = ''${pkgs.sway}/bin/swaymsg "output * dpms off"'';
          resumeCommand = ''${pkgs.sway}/bin/swaymsg "output * dpms on"'';
        }
      ];
      events = [
        {
          event = "lock";
          command = "${pkgs.swaylock}/bin/swaylock";
        }
      ];
    };
  };
}
