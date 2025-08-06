{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
  gdal,
}:

python3Packages.buildPythonApplication rec {
  pname = "tuiview";
  version = "1.3.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ubarsc";
    repo = "tuiview";
    tag = "tuiview-${version}";
    hash = "sha256-e3tpkQlfdmbzwZVp9Hl1p505uaFa0umNyzlOwfHOMCo=";
  };

  build-system = with python3Packages; [
    gdal
    numpy
    setuptools
  ];

  dependencies = with python3Packages; [
    gdal
    numpy
    pyside6
  ];

  meta = {
    description = "Simple Raster Viewer";
    homepage = "https://tuiview.org";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "tuiview";
  };
}
