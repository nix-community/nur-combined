{ pkgs, ... }:
{
  sane.programs.gthumb = {
    # compile without webservices to avoid the expensive webkitgtk dependency
    package = pkgs.gthumb.override { withWebservices = false; };
    mime.associations = {
      "image/heif" = "org.gnome.gThumb.desktop";  # apple codec
      "image/png" = "org.gnome.gThumb.desktop";
      "image/jpeg" = "org.gnome.gThumb.desktop";
      "image/svg+xml" = "org.gnome.gThumb.desktop";
    };
  };
}
