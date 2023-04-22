{ lib
, fetchFromGitHub
, stdenv
, libgee
, libglibutil
, gtk3
, gtk-layer-shell
, meson
, vala
, pkg-config
, cmake
, glib
, ninja
}: stdenv.mkDerivation rec {
  pname = "Hybridbar";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "hcsubser";
    repo = pname;
    rev = version;
    sha256 = "sha256-IiIkqsw+OMu6aqx9Et+cP0vXY19s+SGsTfikWX5r/cY=";
  };

  profile = ''
    XDG_DATA_DIRS=$out/share/gsettings-schemas/$name:$XDG_DATA_DIRS";
  '';

  buildInputs = [ libgee libglibutil.dev gtk3.dev gtk-layer-shell glib.dev ];
  nativeBuildInputs = [ meson vala cmake pkg-config ninja ];

  meta = with lib; {
    description = "A status bar focused on wlroots Wayland compositors";
    homepage = "https://github.com/vars1ty/HybridBar";
    license = licenses.mit;
    maintainers = with maintainers; [ minion3665 ];
  };
}
