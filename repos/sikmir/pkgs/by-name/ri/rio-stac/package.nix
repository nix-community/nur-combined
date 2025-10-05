{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "rio-stac";
  version = "0.11.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "developmentseed";
    repo = "rio-stac";
    tag = version;
    hash = "sha256-3MAqBhekkjJOQnE1B7GxZiFcjkbhhsON01ciKPvGa4g=";
  };

  build-system = with python3Packages; [ flit ];

  dependencies = with python3Packages; [
    rasterio
    pystac
  ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    jsonschema
  ];

  disabledTests = [ "test_create_item" ];

  meta = {
    description = "Create STAC item from raster datasets";
    homepage = "https://developmentseed.org/rio-stac/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
