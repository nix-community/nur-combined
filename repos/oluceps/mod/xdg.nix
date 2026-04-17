{
  flake.modules.nixos.xdg =
    { pkgs, lib, ... }:
    {
      xdg = {
        terminal-exec = {
          enable = true;
          settings = {
            default = [ "foot.desktop" ];
          };
        };
        mime = {
          enable = true;
          defaultApplications = {
            "application/x-xdg-protocol-tg" = [ "org.telegram.desktop.desktop" ];
            "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop" ];
            "application/pdf" = [ "sioyek.desktop" ];
            "ppt/pptx" = [ "wps-office-wpp.desktop" ];
            "doc/docx" = [ "wps-office-wps.desktop" ];
            "xls/xlsx" = [ "wps-office-et.desktop" ];
            "application/epub+zip" = [ "com.github.johnfactotum.Foliate.desktop" ];
            "x-scheme-handler/terminal" = [ "foot.desktop" ];
          }
          // lib.genAttrs [
            "x-scheme-handler/about"
            "x-scheme-handler/http"
            "x-scheme-handler/https"
            "x-scheme-handler/mailto"
            "text/html"
          ] (_: "chromium-browser.desktop")
          // lib.genAttrs [
            "image/jpeg"
            "image/png"
            "image/gif"
            "image/webp"
            "image/tiff"
            "image/x-tga"
            "image/vnd-ms.dds"
            "image/x-dds"
            "image/bmp"
            "image/vnd.microsoft.icon"
            "image/vnd.radiance"
            "image/x-exr"
            "image/x-portable-bitmap"
            "image/x-portable-graymap"
            "image/x-portable-pixmap"
            "image/x-portable-anymap"
            "image/x-qoi"
            "image/qoi"
            "image/svg+xml"
            "image/svg+xml-compressed"
            "image/avif"
            "image/heic"
            "image/jxl"
          ] (_: "org.gnome.Loupe.desktop")
          // lib.genAttrs [
            "inode/directory"
            "inode/mount-point"
          ] (_: "org.gnome.Nautilus.desktop")
          // lib.genAttrs [
            "text/plain"
            "application/toml"
            "application/json"
            "application/yaml"
            "application/javascript"
            "application/json5"
            "application/x-ini-file"
            "text/css"
            "text/csv"
            "text/english"
            "text/x-makefile"
            "text/x-c++hdr"
            "text/x-c++src"
            "text/x-chdr"
            "text/x-csrc"
            "text/x-java"
            "text/x-moc"
            "text/x-pascal"
            "text/x-tcl"
            "text/x-tex"
            "application/x-shellscript"
            "text/x-c"
            "text/x-c++"
          ] (_: "Helix.desktop")
          // lib.genAttrs [
            "video/mp4"
            "video/mkv"
            "x-scheme-handler/video"
          ] (_: "vlc.desktop");
        };
        portal = {
          enable = true;
          # WARNING: this broken xdg-open
          # xdgOpenUsePortal = true;
          extraPortals = [
            # pkgs.xdg-desktop-portal-gtk
            pkgs.xdg-desktop-portal-gnome
          ];
          configPackages = [ pkgs.niri ];
        };
      };

    };
}
