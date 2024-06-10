{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.dotfiles.gnome;
in {
  options.dotfiles.gnome = {
    enable = mkEnableOption "Enable GNOME options";
  };

  config = mkIf cfg.enable {
    dconf.settings = if pkgs.stdenv.isLinux then {
      "org/gnome/desktop/peripherals/touchpad" = {
        "natural-scroll" = false;
        "tap-to-click" = true;
      };

      "org/gnome/desktop/interface" = {
        enable-hot-corners = false;
        show-battery-percentage = true;
      };

      "org/gnome/nautilus/preferences" = { default-folder-viewer="list-view"; };
      "org/gnome/nautilus/list-view" = { default-zoom-level="small"; };

      "org/gnome/settings-daemon/peripherals/touchscreen" = { orientation-lock=true; };
      "org/gnome/desktop/datetime" = { automatic-timezone = true; };
      "org/gnome/system/location" = { enabled = true; };
      "org/gnome/mutter" = { edge-tiling = true; };

      "org/gnome/desktop/app-folders" = { folder-children = ["LibreOffice" "Utilities" ]; };
      "org/gnome/desktop/app-folders/folders/LibreOffice" = {
        name = "LibreOffice";
        apps = [
          "org.libreoffice.LibreOffice.desktop"
          "org.libreoffice.LibreOffice.base.desktop"
          "org.libreoffice.LibreOffice.calc.desktop"
          "org.libreoffice.LibreOffice.draw.desktop"
          "org.libreoffice.LibreOffice.impress.desktop"
          "startcenter.desktop"
          "org.libreoffice.LibreOffice.math.desktop"
          "org.libreoffice.LibreOffice.writer.desktop"
          # "math.desktop"
          # "writer.desktop"
          # "impress.desktop"
          # "draw.desktop"
          # "calc.desktop"
          # "base.desktop"
        ];
      };

      "org/gnome/shell" = { app-picker-layout = []; };
     } else {};
  };
}