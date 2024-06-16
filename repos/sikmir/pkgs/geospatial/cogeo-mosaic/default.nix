{
  lib,
  fetchFromGitHub,
  python3Packages,
  supermorecado,
}:

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

  build-system = with python3Packages; [
    hatchling
    hatch-fancy-pypi-readme
  ];

  dependencies = with python3Packages; [
    morecantile
    shapely
    pydantic
    pydantic-settings
    httpx
    rasterio
    rio-tiler
    supermorecado
    cachetools
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  doCheck = false;

  disabledTests = [
    "test_mosaic_crud_error" # requires network access
    "test_abs_backend"
  ];

  meta = {
    description = "Create and use COG mosaic based on mosaicJSON";
    homepage = "https://developmentseed.org/cogeo-mosaic/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
