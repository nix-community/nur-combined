{ pkgs, ... }:
{
  sane.programs.loupe = {
    sandbox.method = "bwrap";
    sandbox.wrapperType = "wrappedDerivation";
    sandbox.whitelistWayland = true;
    sandbox.autodetectCliPaths = "parent";
    sandbox.extraHomePaths = [
      "Pictures"
      "Pictures/servo-macros"
      "Videos"
      "Videos/servo"
      "dev"
      "records"
      "ref"
      "tmp"
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

