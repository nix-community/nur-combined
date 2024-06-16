{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "pysheds";
  version = "0.4";

  src = fetchFromGitHub {
    owner = "mdbartos";
    repo = "pysheds";
    rev = version;
    hash = "sha256-cIx/TPPLYsHEgvHtyZY5psRwqtvKQkJ/SnafT2btLBI=";
  };

  dependencies = with python3Packages; [
    scikitimage
    affine
    geojson
    rasterio
    pyproj
    numba
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
