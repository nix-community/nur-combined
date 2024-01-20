{ pkgs, ... }:
{
  sane.programs.gthumb = {
    # compile without webservices to avoid the expensive webkitgtk dependency
    packageUnwrapped = pkgs.gthumb.override { withWebservices = false; };
    mime.priority = 200;  # gthumb is kinda bloated image/gallery viewer
    mime.associations = {
      "image/gif" = "org.gnome.gThumb.desktop";
      "image/heif" = "org.gnome.gThumb.desktop";  # apple codec
      "image/png" = "org.gnome.gThumb.desktop";
      "image/jpeg" = "org.gnome.gThumb.desktop";
      "image/svg+xml" = "org.gnome.gThumb.desktop";
      "image/webp" = "org.gnome.gThumb.desktop";
    };
  };
}
