{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "smoothify";
  version = "0.3.3";
  pyproject = true;

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "DPIRD-DMA";
    repo = "Smoothify";
    tag = "v${finalAttrs.version}";
    hash = "sha256-J8GVRiy0b4uIAcpAsKIB/QhuYylszy7cpul0495S++k=";
  };

  build-system = with python3Packages; [ setuptools-scm ];

  dependencies = with python3Packages; [
    geopandas
    joblib
    numpy
    scipy
    shapely
  ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    pytest-xdist
  ];

  meta = {
    description = "Transform pixelated geometries from raster data into smooth natural looking features";
    homepage = "https://github.com/DPIRD-DMA/Smoothify";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
