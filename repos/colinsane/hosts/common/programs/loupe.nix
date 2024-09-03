{ pkgs, ... }:
{
  sane.programs.loupe = {
    # loupe is marked "dbus activatable", which does not seem to actually work (at least when launching from Firefox or Nautilus)
    packageUnwrapped = pkgs.rmDbusServicesInPlace pkgs.loupe;
    # .overrideAttrs (upstream: {
    #   preFixup = (upstream.preFixup or "") + ''
    #     # 2024/02/21: render bug which affects only moby:
    #     #             large images render blank in several gtk applications.
    #     #             may resolve itself as gtk or mesa are updated.
    #     gappsWrapperArgs+=(--set GSK_RENDERER cairo)
    #   '';
    # }));

    sandbox.method = "bunpen";
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

    mime.associations = {
      "image/avif" = "org.gnome.Loupe.desktop";
      "image/gif" = "org.gnome.Loupe.desktop";
      "image/heif" = "org.gnome.Loupe.desktop";  # apple codec
      "image/png" = "org.gnome.Loupe.desktop";
      "image/jpeg" = "org.gnome.Loupe.desktop";
      "image/svg+xml" = "org.gnome.Loupe.desktop";
      "image/webp" = "org.gnome.Loupe.desktop";
    };
  };
}

