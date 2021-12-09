{ stdenv, fetchFromGitHub, gettext, meson, ninja, pkg-config, python3, vala, wrapGAppsHook, gtk3, json-glib, libgee, mesa, gtk-layer-shell }:

stdenv.mkDerivation rec {
  name = "hybridbar";
  version = "";

  src = fetchFromGitHub {
    owner = "hcsubser";
    repo = "hybridbar";
    rev = "1.0.0";
    sha256 = "1ipxddz5k97q9nn23ybcbxixfjrzkkgi4zdcdaxcnf1yrjm288i2";
  };

  nativeBuildInputs = [
    gettext
    meson
    ninja
    pkg-config
    python3
    vala
    wrapGAppsHook
  ];
 
  buildInputs = [
    gtk3
    json-glib
    libgee
    mesa
    gtk-layer-shell
  ];
}
