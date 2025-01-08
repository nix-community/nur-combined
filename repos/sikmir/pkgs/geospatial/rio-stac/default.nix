{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "rio-stac";
  version = "0.10.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "developmentseed";
    repo = "rio-stac";
    tag = version;
    hash = "sha256-sK03AWDwsUanxl756z/MrroF3cm7hV3dpPhVQ/1cs3E=";
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
