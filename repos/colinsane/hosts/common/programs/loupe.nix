{ pkgs, ... }:
{
  sane.programs.loupe = {
    packageUnwrapped = pkgs.rmDbusServicesInPlace pkgs.loupe;

    sandbox.whitelistDri = true;  #< faster rendering
    sandbox.whitelistWayland = true;
    sandbox.autodetectCliPaths = "parent";
    sandbox.extraHomePaths = [
      "Pictures/albums"
      "Pictures/cat"
      "Pictures/from"
      "Pictures/Photos"
      "Pictures/Screenshots"
      "Pictures/servo-macros"
      "Videos/local"
      "Videos/servo"
      "dev"
      "records"
      "ref"
      "tmp"
    ];

    sandbox.mesaCacheDir = ".cache/loupe/mesa";  # TODO: is this the correct app-id?

    mime.associations = {
      "image/avif" = "org.gnome.Loupe.desktop";
      "image/gif" = "org.gnome.Loupe.desktop";
      "image/heif" = "org.gnome.Loupe.desktop";  # apple codec
      "image/png" = "org.gnome.Loupe.desktop";
      "image/jpeg" = "org.gnome.Loupe.desktop";
      "image/svg+xml" = "org.gnome.Loupe.desktop";
      "image/webp" = "org.gnome.Loupe.desktop";
    };

    # XXX(2024-10-06): even with sandbox.net = "all", loupe fails to open https:// or even http:// media
    # mime.urlAssociations."^https?://.*\.(gif|heif|jpeg|jpg|png|svg|webp)(\\?.*)?$" = "org.gnome.Loupe.desktop";
    # mime.urlAssociations."^https?://i\.imgur.com/.+$" = "org.gnome.Loupe.desktop";
  };
}

