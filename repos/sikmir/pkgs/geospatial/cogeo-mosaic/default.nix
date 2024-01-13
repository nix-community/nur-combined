{ lib, stdenv, fetchFromGitHub, python3Packages, morecantile, supermercado, rio-tiler }:

python3Packages.buildPythonPackage rec {
  pname = "cogeo-mosaic";
  version = "7.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "developmentseed";
    repo = "cogeo-mosaic";
    rev = version;
    hash = "sha256-FJJZvLGBEZpVyfXBqmz6r1obx4HrKmtK0dWusItX3j4=";
  };

  nativeBuildInputs = with python3Packages; [ hatchling hatch-fancy-pypi-readme ];

  propagatedBuildInputs = with python3Packages; [
    morecantile
    shapely
    pydantic
    httpx
    rasterio
    rio-tiler
    supermercado
    cachetools
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  doCheck = false;

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
