{
  lib,
  fetchFromGitHub,
  python3Packages,
  supermorecado,
}:

python3Packages.buildPythonPackage rec {
  pname = "cogeo-mosaic";
  version = "8.2.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "developmentseed";
    repo = "cogeo-mosaic";
    tag = version;
    hash = "sha256-g5ZRdqs/nY1i2xB8UsJjKwdb0BhlR1Bfj4FSPBRJrss=";
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
    inherit (python3Packages.rio-tiler.meta) broken;
  };
}
