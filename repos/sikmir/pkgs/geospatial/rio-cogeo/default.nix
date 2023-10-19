{ lib, stdenv, fetchFromGitHub, python3Packages, morecantile, cogdumper }:

python3Packages.buildPythonPackage rec {
  pname = "rio-cogeo";
  version = "5.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "cogeotiff";
    repo = "rio-cogeo";
    rev = version;
    hash = "sha256-YBFdo/aEk9ytlzLhdC/kV3jwS1atrfYmyxNP8jWBTxs=";
  };

  nativeBuildInputs = with python3Packages; [ flit ];

  propagatedBuildInputs = with python3Packages; [
    click
    rasterio
    numpy
    morecantile
    pydantic
  ];

  doCheck = false;

  nativeCheckInputs = with python3Packages; [ pytestCheckHook cogdumper ];

  meta = with lib; {
    description = "Cloud Optimized GeoTIFF creation and validation plugin for rasterio";
    inherit (src.meta) homepage;
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
  };
}
