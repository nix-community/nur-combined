{ lib, stdenv, fetchFromGitHub, autoreconfHook, wxGTK30-gtk3 }:

stdenv.mkDerivation rec {
  pname = "render_geojson";
  version = "2018-07-11";

  src = fetchFromGitHub {
    owner = "pedro-vicente";
    repo = "render_geojson";
    rev = "ed65a22f45fc09784fa113fe93254492d88663c2";
    hash = "sha256-X8l4eIt6K8B6w2whZFdnKHRUBM2jQQDVIrAFxO1Xbhg=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [ wxGTK30-gtk3 ];

  meta = with lib; {
    description = "C++ geoJSON and topoJSON parser and rendering using the WxWidgets GUI library";
    inherit (src.meta) homepage;
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
