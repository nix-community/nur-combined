# Tangram is a GTK/webkit browser
# it views each tab as a distinct application, persisted, and where the 'home' button action is specific to each tab.
# it supports ephemeral tabs, but UX is heavily geared to GCing those as early as possible.

{ pkgs, ... }:
{
  sane.programs.tangram = {
    # XXX(2023/07/08): running on moby without this hack fails, with:
    # - `bwrap: Can't make symlink at /var/run: File exists`
    # see epiphany.nix for more info
    package = pkgs.tangram.overrideAttrs (upstream: {
      preFixup = ''
        gappsWrapperArgs+=(
          --set WEBKIT_DISABLE_SANDBOX_THIS_IS_DANGEROUS "1"
        );
      '' + (upstream.preFixup or "");
    });
    persist.private = [
      ".cache/Tangram"
      ".local/share/Tangram"
    ];
  };
}
