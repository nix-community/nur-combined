{
  desktop-file-utils,
  fetchFromGitLab,
  fetchzip,
  fetchurl,
  # gitUpdater,
  gtk4,
  json-glib,
  lib,
  libadwaita,
  libsoup_3,
  linkFarm,
  meson,
  ninja,
  pkg-config,
  stdenv,
  vala,
  webkitgtk_6_0,
  wrapGAppsHook4,
}:
let
  vendored-raw = {
    # these are specified in build-aux/dev.geopjr.Archives.Devel.json
    "offline/ruffle" = fetchzip {
      url = "https://github.com/ruffle-rs/ruffle/releases/download/nightly-2025-07-01/ruffle-nightly-2025_07_01-web-selfhosted.zip";
      hash = "sha256-4bVTE7grgoS0mc/wjCIUo+XGXXzXnGTzY+ZBAczWuQU=";
      stripRoot = false;
    };
    "offline/single-file.js" = fetchurl {
      url = "https://raw.githubusercontent.com/gildas-lormeau/SingleFile-MV3/735ee59616129f16244262a36923ef92dd8d5b9a/lib/single-file.js";
      hash = "sha256-R6UCJiJwYlkVa1n2Cv40vjKtC6X065GWPsU8uaXrVYo=";
    };
    "offline/single-file-bootstrap.js" = fetchurl {
      url = "https://raw.githubusercontent.com/gildas-lormeau/SingleFile-MV3/735ee59616129f16244262a36923ef92dd8d5b9a/lib/single-file-bootstrap.js";
      hash = "sha256-E561dvvU60EQmRUe2dbty5vOeeCg1PjJ8QTDHMABPj8=";
    };
    "offline/single-file-hooks-frames.js" = fetchurl {
      url = "https://raw.githubusercontent.com/gildas-lormeau/SingleFile-MV3/735ee59616129f16244262a36923ef92dd8d5b9a/lib/single-file-hooks-frames.js";
      hash = "sha256-TDToXa+5vD9bKcG9S2E/BBlT+DtBESfTdz6QfyhWU3U=";
    };
    "offline/single-file-zip.min.js" = fetchurl {
      url = "https://raw.githubusercontent.com/gildas-lormeau/SingleFile-MV3/735ee59616129f16244262a36923ef92dd8d5b9a/lib/single-file-zip.min.js";
      hash = "sha256-FBg4DWpXye5oiIN07V2hKz+rst9OKBWCUUMkjOPZOlw=";
    };
    "data/vendored/ui.js" = fetchurl {
      url = "https://raw.githubusercontent.com/webrecorder/replayweb.page/6112438383e9a4c419f4d3b0967016a595692ec8/ui.js";
      hash = "sha256-Rh+265pCiwZPgHDuclUHw9IEQug2l1fbs6hoHYddTAQ=";
    };
    "data/vendored/sw.js" = fetchurl {
      url = "https://raw.githubusercontent.com/webrecorder/replayweb.page/6112438383e9a4c419f4d3b0967016a595692ec8/sw.js";
      hash = "sha256-DMLqHpIfV5BBy9o/eBZ25chPCyW8phNCqCUTU/ar5Kk=";
    };
    "data/vendored/adblock/adblock.gz" = fetchurl {
      url = "https://raw.githubusercontent.com/webrecorder/replayweb.page/6112438383e9a4c419f4d3b0967016a595692ec8/adblock/adblock.gz";
      hash = "sha256-w3oTnB2NP6c6oQqKvFMvmQsWqOkEq5dKsQGAhis4w3c=";
    };
    "offline/kiwix" = fetchzip {
      url = "https://github.com/kiwix/kiwix-js/archive/380f5e3df7a05f0f957021867495c6305b98e7c9.zip";
      hash = "sha256-6iG/RfgpCbHybA5p6smr60KlwtqbF5U3xnzDH0wA4Ac=";
    };
  };
  vendored = linkFarm "archives-vendored" (lib.mapAttrsToList
    (name: deriv: {
      inherit name;
      path = deriv;
    })
    vendored-raw
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "archives";
  version = "0.6.0";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "GeopJr";
    repo = "Archives";
    rev = "v${finalAttrs.version}";
    hash = "sha256-OUy36zJY7nduIi58ZKrn6JKFXt8BK6Bbd3vSH7dIM/Q=";
  };

  postPatch = ''
    # link in the vendored data.
    # needs to be RW so that `make update_bundle` can write the directory
    for d in data/vendored offline ; do
      cp -R --dereference ${vendored}/"$d" "$d"
      chmod +w -R "$d"
    done

    make offline=1 update_bundle
  '';

  nativeBuildInputs = [
    desktop-file-utils
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    json-glib
    libadwaita
    libsoup_3
    webkitgtk_6_0
  ];

  strictDeps = true;

  passthru = {
    inherit vendored vendored-raw;
    # TODO: write an updateScript that supports Archives' method of vendoring
    # updateScript = gitUpdater {
    #   rev-prefix = "v";
    # };
  };

  meta = {
    homepage = "https://archives.geopjr.dev/";
    description = "Create and view web archives";
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
