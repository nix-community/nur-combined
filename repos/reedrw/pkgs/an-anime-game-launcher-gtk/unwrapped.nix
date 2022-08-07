{ rustPlatform, fetchFromGitLab
, pkg-config
, openssl
, glib
, pango
, gdk-pixbuf
, gtk4
, libadwaita
, blueprint-compiler
, gobject-introspection
, makeWrapper
, gsettings-desktop-schemas
, wrapGAppsHook4
, runtimeShell
, mangohud
, xdelta
, libunwind
, librsvg
}:

rustPlatform.buildRustPackage rec {
  pname = "an-anime-game-launcher-gtk";
  version = "1.0.0";

  src = fetchFromGitLab {
    owner = "an-anime-team";
    repo = "an-anime-game-launcher-gtk";
    rev = version;
    sha256 = "sha256-k+qA5mETEEt/j0zbOOccGZ9ElTGnwqEuohFzc7I1AvA=";
    fetchSubmodules = true;
  };

  patches = [
    ./blp-compiler.patch
  ];

  cargoSha256 = "sha256-p9R/C7yeDX/OmsFgq6QAanN/gcPhQqp6aAnnLylhEzo=";

  nativeBuildInputs = [
    pkg-config
    gtk4
    glib
    blueprint-compiler
    wrapGAppsHook4
  ];

  buildInputs = [
    gdk-pixbuf
    openssl
    librsvg
    pango
    gsettings-desktop-schemas
    libadwaita
  ];
}
