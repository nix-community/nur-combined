{ stdenv
, gnome-feeds
, gpodder
, makeWrapper
, python3
, static-nix-shell
, symlinkJoin
}:

let
  remove-extra = static-nix-shell.mkPython3Bin {
    pname = "gpodder-remove-extra";
    src = ./.;
    pyPkgs = _ps: {
      "gnome-feeds.listparser" = gnome-feeds.listparser;
    };
    pkgs = {
      inherit gpodder;
    };
  };
in
# we use a symlinkJoin so that we can inherit the .desktop and icon files from the original gPodder
(symlinkJoin {
  name = "gpodder-configured";
  paths = [ gpodder remove-extra ];
  nativeBuildInputs = [ makeWrapper ];

  # gpodder keeps all its feeds in a sqlite3 database.
  # we can configure the feeds externally by wrapping gpodder and just instructing it to import
  # a feedlist every time we run it.
  # repeat imports are deduplicated by url, even when offline.
  postBuild = ''
    makeWrapper $out/bin/gpodder $out/bin/gpodder-configured \
      --run "$out/bin/gpodder-remove-extra ~/.config/gpodderFeeds.opml" \
      --run "$out/bin/gpo import ~/.config/gpodderFeeds.opml" \

    # fix up the .desktop file to invoke our wrapped application
    orig_desktop=$(readlink $out/share/applications/gpodder.desktop)
    unlink $out/share/applications/gpodder.desktop
    sed "s:Exec=.*:Exec=$out/bin/gpodder-configured:" $orig_desktop > $out/share/applications/gpodder.desktop
  '';

  passthru = {
    remove-extra = remove-extra;
  };
})
