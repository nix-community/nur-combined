{
  lib,
  fetchFromGitHub,
  python3Packages,
  cogdumper,
}:

python3Packages.buildPythonPackage rec {
  pname = "rio-cogeo";
  version = "5.3.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "cogeotiff";
    repo = "rio-cogeo";
    rev = version;
    hash = "sha256-PzhUlip2LYO6DhC9O2aeoQGE59QXKq2e0v6/yxeFvjM=";
  };

  build-system = with python3Packages; [ flit ];

  dependencies = with python3Packages; [
    click
    rasterio
    numpy
    morecantile
    pydantic
  ];

  doCheck = false;

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    cogdumper
  ];

  meta = {
    description = "Cloud Optimized GeoTIFF creation and validation plugin for rasterio";
    homepage = "https://github.com/cogeotiff/rio-cogeo";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
