{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  wxGTK32,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "render_geojson";
  version = "0-unstable-2018-07-11";

  src = fetchFromGitHub {
    owner = "pedro-vicente";
    repo = "render_geojson";
    rev = "ed65a22f45fc09784fa113fe93254492d88663c2";
    hash = "sha256-X8l4eIt6K8B6w2whZFdnKHRUBM2jQQDVIrAFxO1Xbhg=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [ wxGTK32 ];

  meta = {
    description = "C++ geoJSON and topoJSON parser and rendering using the WxWidgets GUI library";
    homepage = "https://github.com/pedro-vicente/render_geojson";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
