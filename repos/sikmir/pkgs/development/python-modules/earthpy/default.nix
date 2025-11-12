{
  lib,
  stdenv,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage rec {
  pname = "earthpy";
  version = "0.9.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "earthlab";
    repo = "earthpy";
    tag = "v${version}";
    hash = "sha256-MCyeFXtjOqnVarSUk7Z/+Y5oNhYLlxznjWHQOCgUOIc=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    geopandas
    matplotlib
    numpy
    rasterio
    scikit-image
    requests
  ];

  doCheck = false;

  meta = {
    description = "A package built to support working with spatial data using open source python";
    homepage = "https://github.com/earthlab/earthpy";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
