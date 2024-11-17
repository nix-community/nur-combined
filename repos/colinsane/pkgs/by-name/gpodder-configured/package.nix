{
  gpodder,
  listparser,
  makeWrapper,
  static-nix-shell,
  symlinkJoin,
}:

let
  remove-extra = static-nix-shell.mkPython3 {
    pname = "gpodder-ensure-feeds";
    srcRoot = ./.;
    pkgs = {
      # important for this to explicitly use `gpodder` here, because it may be overriden/different from the toplevel `gpodder`!
      inherit gpodder listparser;
    };
  };
in
# we use a symlinkJoin so that we can inherit the .desktop and icon files from the original gPodder
(symlinkJoin {
  name = "${gpodder.pname}-configured";
  paths = [ gpodder remove-extra ];
  nativeBuildInputs = [
    makeWrapper
  ];

  # gpodder keeps all its feeds in a sqlite3 database.
  # we can configure the feeds externally by wrapping gpodder and just instructing it to import
  # a feedlist every time we run it.
  # repeat imports are deduplicated by url, even when offline.
  postBuild = ''
    wrapProgram $out/bin/gpodder \
      $extraMakeWrapperArgs \
      --run "$out/bin/gpodder-ensure-feeds"' ~/.config/gpodderFeeds.opml "$@" || true' \
      --run 'while [[ -n "$1" && "$1" != -- && "$1" != --help ]]; do shift; done ; if [[ "$1" == --help ]]; then exit; elif [[ "$1" == -- ]]; then shift; fi'

    # fix up the .desktop file to invoke our wrapped application
    # (rather, invoke `gpodder` by PATH, which could be this, or an outer layer of wrapping)
    orig_desktop=$(readlink $out/share/applications/gpodder.desktop)
    unlink $out/share/applications/gpodder.desktop
    sed "s:Exec=.*/gpodder:Exec=gpodder:" $orig_desktop > $out/share/applications/gpodder.desktop
  '';

  passthru = {
    inherit gpodder remove-extra;
  };
})
