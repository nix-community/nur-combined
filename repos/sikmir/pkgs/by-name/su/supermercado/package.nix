{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "supermercado";
  version = "0.3.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mapbox";
    repo = "supermercado";
    tag = version;
    hash = "sha256-5wE4XGRmMMFOCT4YCn4lwu9O6nn2wqYeQoU/cEjkv0g=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    click-plugins
    rasterio
    mercantile
    numpy
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  disabledTests = [
    "test_burn_tile_center_point_roundtrip"
    "test_burn_tile_center_lines_roundtrip"
    "test_burn_cli_tile_shape"
  ];

  meta = {
    description = "Supercharger for mercantile";
    homepage = "https://github.com/mapbox/supermercado";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
