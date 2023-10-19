{ lib, stdenv, fetchFromGitHub, python3Packages, morecantile, supermercado, rio-tiler }:

python3Packages.buildPythonPackage rec {
  pname = "cogeo-mosaic";
  version = "5.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "developmentseed";
    repo = "cogeo-mosaic";
    rev = version;
    hash = "sha256-jwl0URSt77nk3IMdMMCWGF0U+giRA/8fSs0nNVmu9Dk=";
  };

  nativeBuildInputs = with python3Packages; [ hatchling hatch-fancy-pypi-readme ];

  propagatedBuildInputs = with python3Packages; [
    httpx
    morecantile
    shapely
    cachetools
    supermercado
    rio-tiler
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  disabledTests = [
    "test_mosaic_crud_error" # requires network access
    "test_abs_backend"
  ];

  meta = with lib; {
    description = "Create and use COG mosaic based on mosaicJSON";
    homepage = "https://developmentseed.org/cogeo-mosaic/";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
