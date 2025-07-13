{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "pysheds";
  version = "0.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mdbartos";
    repo = "pysheds";
    tag = version;
    hash = "sha256-cIx/TPPLYsHEgvHtyZY5psRwqtvKQkJ/SnafT2btLBI=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    affine
    geojson
    looseversion
    numba
    numpy
    pandas
    pyproj
    rasterio
    scikitimage
    scipy
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  doCheck = false;

  meta = {
    description = "Simple and fast watershed delineation in python";
    homepage = "https://github.com/mdbartos/pysheds";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
