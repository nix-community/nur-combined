{ stdenv, lib, fetchFromGitHub, fetchpatch
, pkgconfig, meson, ninja
, wayland, wayland-protocols
, gtk3, gtk-layer-shell
}:

let
  rev = "0123bab02f672d2913be6df0cded19ffd310c745";
in
stdenv.mkDerivation rec {
  pname = "wlr-sunclock";
  version = "unstable-2020-08-28";

  src = fetchFromGitHub {
    owner = "sentriz";
    repo = "wlr-sunclock";
    # rev = "v${version}";
    inherit rev;
    hash = "sha256-kbHds4pz34VXAmXs77nnI2puUpQa3ZNBUXC8dg2T7Z0=";
  };

  nativeBuildInputs = [ pkgconfig meson ninja ];

  buildInputs = [ wayland wayland-protocols gtk3 gtk-layer-shell ];

  meta = with lib; {
    description = "Wayland desktop widget to show the sun's shadows on earth";
    homepage = "https://github.com/sentriz/wlr-sunclock";
    license = licenses.lgpl3;
    platform = platforms.linux;
    maintainer = [ maintainers.berbiche ];
  };
}
