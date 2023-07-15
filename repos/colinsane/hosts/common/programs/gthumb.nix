{ pkgs, ... }:
{
  sane.programs.gthumb = {
    # compile without webservices to avoid the expensive webkitgtk dependency
    package = pkgs.gthumb.override { withWebservices = false; };
    mime.associations."image/heif" = "org.gnome.gThumb.desktop";  # apple codec
    mime.associations."image/png" = "org.gnome.gThumb.desktop";
    mime.associations."image/jpeg" = "org.gnome.gThumb.desktop";
  };
}
