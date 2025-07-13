{
  lib,
  fetchFromGitHub,
  python3Packages,
  supermercado,
}:

python3Packages.buildPythonApplication rec {
  pname = "rio-mbtiles";
  version = "1.6.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mapbox";
    repo = "rio-mbtiles";
    tag = version;
    hash = "sha256-Kje443Qqs8+Jcv3PnTrMncaoaGDdjrzTcd42NYIenuU=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    click
    cligj
    mercantile
    numpy
    supermercado
    tqdm
    shapely
  ];

  pythonRelaxDeps = true;

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  disabledTests = [
    "test_process_tile"
    "test_export_count"
  ];

  meta = {
    description = "A plugin command for the Rasterio CLI that exports a raster dataset to an MBTiles 1.1 SQLite file";
    homepage = "https://github.com/mapbox/rio-mbtiles";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
