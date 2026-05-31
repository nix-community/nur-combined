{
  lib,
  stdenv,
  python3Packages,
  fetchFromGitHub,
  gobject-introspection,
  pango,
  thinplatespline,
  maprec,
  ozi-map,
  pyimagequant,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication {
  pname = "map-tiler";
  version = "0-unstable-2026-03-28";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "wladich";
    repo = "map-tiler";
    rev = "f4749cbf64f226218ae3c03ec8aa35a249e70300";
    hash = "sha256-VD7MmG7V551fODLIfu/Xwv+841IFvfyTdCa+5LFh4XY=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.9.21,<0.10.0" uv_build
  '';

  build-system = with python3Packages; [ uv-build ];

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [
    gobject-introspection
    pango
  ];

  pythonRelaxDeps = true;

  dependencies = with python3Packages; [
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
