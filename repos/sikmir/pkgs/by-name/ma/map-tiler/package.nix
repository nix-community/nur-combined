{
  lib,
  stdenv,
  python311Packages,
  fetchFromGitHub,
  gobject-introspection,
  pango,
  thinplatespline,
  maprec,
  ozi-map,
  pyimagequant,
  wrapGAppsHook,
}:

python311Packages.buildPythonApplication {
  pname = "map-tiler";
  version = "0-unstable-2022-08-06";
  pyproject = true;

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

  build-system = with python311Packages; [ setuptools ];

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook
  ];

  buildInputs = [
    gobject-introspection
    pango
  ];

  dependencies = with python311Packages; [
    pyyaml
    pyproj
    pypng
    pillow
    pycairo
    thinplatespline
    maprec
    ozi-map
    pyimagequant
    pygobject3
  ];

  doCheck = false;

  meta = {
    description = "Raster maps to map tiles";
    homepage = "https://github.com/wladich/map-tiler";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
