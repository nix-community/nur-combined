{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
  gdal,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "tuiview";
  version = "1.3.6";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ubarsc";
    repo = "tuiview";
    tag = "tuiview-${finalAttrs.version}";
    hash = "sha256-eC9Ece8ROHXJZR7TWaGKnp9fCCZGyQXwnl+2T0Wtr+A=";
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
})
