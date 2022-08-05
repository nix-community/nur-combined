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
  version = "1.0.0-rc2";

  src = fetchFromGitLab {
    owner = "an-anime-team";
    repo = "an-anime-game-launcher-gtk";
    rev = "08a6e3bc5e1802a2041ccc91889ce6d47970cfc6";
    sha256 = "sha256-d9xaUHcfPryDD8Rz8ntwfToacMPBRJUQNTjUccUKZqc=";
    fetchSubmodules = true;
  };

  patches = [
    ./blp-compiler.patch
  ];

  cargoSha256 = "sha256-c5/eRBeYkB16k0EMu8teIF3E1eJko3DMhZSp+ery2h4=";

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
