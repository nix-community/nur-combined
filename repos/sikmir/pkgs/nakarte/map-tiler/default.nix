{
  lib,
  stdenv,
  python3Packages,
  fetchFromGitHub,
  gobject-introspection,
  pango,
  thinplatespline,
  maprec,
  ozi_map,
  pyimagequant,
  wrapGAppsHook,
}:

python3Packages.buildPythonApplication rec {
  pname = "map-tiler";
  version = "0-unstable-2022-08-06";

  src = fetchFromGitHub {
    owner = "wladich";
    repo = "map-tiler";
    rev = "5554d207730e2cbcb59004a50c83c9420769a49c";
    hash = "sha256-suBS0jCGX09mY2fc2UsWr1ptySZkA68Kp6iSIJQeWuA=";
  };

  postPatch = ''
    substituteInPlace setup.cfg \
      --replace-fail " @ git+https://github.com/wladich/thinplatespline.git" "" \
      --replace-fail " @ git+https://github.com/wladich/maprec.git" "" \
      --replace-fail " @ git+https://github.com/wladich/ozi_map.git" "" \
      --replace-fail " @ git+https://github.com/wladich/pyimagequant.git" ""
  '';

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook
  ];

  buildInputs = [
    gobject-introspection
    pango
  ];

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

  meta = {
    description = "Raster maps to map tiles";
    inherit (src.meta) homepage;
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
