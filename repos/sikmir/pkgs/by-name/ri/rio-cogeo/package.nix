{
  lib,
  fetchFromGitHub,
  python3Packages,
  cogdumper,
}:

python3Packages.buildPythonPackage rec {
  pname = "rio-cogeo";
  version = "5.4.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "cogeotiff";
    repo = "rio-cogeo";
    tag = version;
    hash = "sha256-BMIUC5h2E9hTeLXGYvkkFuh6DsYVwQHSWAtJZvqVhV8=";
  };

  build-system = with python3Packages; [ flit ];

  dependencies = with python3Packages; [
    click
    rasterio
    numpy
    morecantile
    pydantic
  ];

  pythonRelaxDeps = [ "morecantile" ];

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
