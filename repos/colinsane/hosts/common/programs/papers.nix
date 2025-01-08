{ ... }:
{
  sane.programs.papers = {
    # packageUnwrapped = pkgs.papers.overrideAttrs (upstream: {
    #   # allow loading of http documents
    #   buildInputs = upstream.buildInputs ++ [ pkgs.glib-networking ];
    # });

    buildCost = 2;  #< webkitgtk
    sandbox.method = null;  #< TODO: enable, after fixing embedded media playback
    sandbox.whitelistDri = true;  #< speedier
    sandbox.whitelistWayland = true;
    sandbox.autodetectCliPaths = "existingFile";
    sandbox.mesaCacheDir = ".cache/papers/mesa";  # TODO: is this the correct app-id?

    sandbox.whitelistPortal = [ "OpenURI" ];

    mime.associations."application/pdf" = "org.gnome.Papers.desktop";
    # XXX(2024-10-06): even with `sandbox.net = "all"` and glib-networking, papers can only open *http* URLs and not https
    # mime.urlAssociations."^https?://.*\.pdf(\\?.*)?$" = "org.gnome.Papers.desktop";
  };
}
