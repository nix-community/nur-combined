{ lib, stdenv, fetchFromGitHub, python3Packages, supermercado }:

python3Packages.buildPythonApplication rec {
  pname = "rio-mbtiles";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "mapbox";
    repo = pname;
    rev = version;
    hash = "sha256-Kje443Qqs8+Jcv3PnTrMncaoaGDdjrzTcd42NYIenuU=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace "shapely~=1.7.0" "shapely"
  '';

  propagatedBuildInputs = with python3Packages; [
    click
    cligj
    mercantile
    numpy
    supermercado
    tqdm
    shapely
  ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  disabledTests = [
    "test_process_tile"
  ];

  meta = with lib; {
    description = "A plugin command for the Rasterio CLI that exports a raster dataset to an MBTiles 1.1 SQLite file";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
