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
  version = "1.0.0-rc1";

  src = fetchFromGitLab {
    owner = "an-anime-team";
    repo = "an-anime-game-launcher-gtk";
    rev = "bcdb0217ade88eb9ac226d76a884f041ae11049d";
    sha256 = "sha256-vSnt1UDdH/5L+9we5fgj2thtb9qx0zZe2voK0SFvqFA=";
    fetchSubmodules = true;
  };

  patches = [
    ./blp-compiler.patch
  ];

  cargoSha256 = "sha256-3YxwKWBduF3B0fKOhC+RqGgE+SldoqGuMMw/TassTNs=";

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
