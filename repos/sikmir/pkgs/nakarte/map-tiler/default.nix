{ lib
, stdenv
, python3Packages
, fetchFromGitHub
, gobject-introspection
, pango
, thinplatespline
, maprec
, ozi_map
, pyimagequant
, wrapGAppsHook
}:

python3Packages.buildPythonApplication rec {
  pname = "map-tiler";
  version = "2022-08-06";

  src = fetchFromGitHub {
    owner = "wladich";
    repo = "map-tiler";
    rev = "28372c77f73282c234a236ad59672ed28721d88b";
    hash = "sha256-P5HXWCxxcGX/QRcRVsMAng/aZI0zBjkOgSEyVCjuAYg=";
  };

  postPatch = ''
    substituteInPlace setup.cfg \
      --replace " @ git+https://github.com/wladich/thinplatespline.git" "" \
      --replace " @ git+https://github.com/wladich/maprec.git" "" \
      --replace " @ git+https://github.com/wladich/ozi_map.git" "" \
      --replace " @ git+https://github.com/wladich/pyimagequant.git" ""
  '';

  nativeBuildInputs = [ gobject-introspection wrapGAppsHook ];

  buildInputs = [ gobject-introspection pango ];

  propagatedBuildInputs = with python3Packages; [
    pyyaml
    pyproj
    pypng
    pillow
    pycairo
    thinplatespline
    maprec
    ozi_map
    pyimagequant
    pygobject3
  ];

  doCheck = false;

  meta = with lib; {
    description = "Raster maps to map tiles";
    inherit (src.meta) homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    broken = stdenv.isDarwin;
  };
}
