{ pkgs, ... }:
{
  sane.programs.loupe = {
    sandbox.method = "bwrap";
    sandbox.wrapperType = "wrappedDerivation";
    sandbox.extraHomePaths = [
      "Pictures"
      "Videos"
      "dev"
      "records"
      "ref"
      "tmp"
    ];
    sandbox.extraPaths = [
      "/mnt/servo/media/Pictures"
      "/mnt/servo/media/Videos"
    ];
    mime.associations = {
      "image/gif" = "org.gnome.Loupe.desktop";
      "image/heif" = "org.gnome.Loupe.desktop";  # apple codec
      "image/png" = "org.gnome.Loupe.desktop";
      "image/jpeg" = "org.gnome.Loupe.desktop";
      "image/svg+xml" = "org.gnome.Loupe.desktop";
      "image/webp" = "org.gnome.Loupe.desktop";
    };
  };
}

