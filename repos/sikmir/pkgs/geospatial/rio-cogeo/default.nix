{ lib, stdenv, fetchFromGitHub, python3Packages, morecantile }:

python3Packages.buildPythonPackage rec {
  pname = "rio-cogeo";
  version = "3.5.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "cogeotiff";
    repo = "rio-cogeo";
    rev = version;
    hash = "sha256-lvGog5Pzbc7v49lZMxomwDszJN/CVzu+AAkb5in3IoY=";
  };

  nativeBuildInputs = with python3Packages; [
    flit-core
  ];

  propagatedBuildInputs = with python3Packages; [
    click
    rasterio
    numpy
    morecantile
    pydantic
  ];

  meta = with lib; {
    description = "Cloud Optimized GeoTIFF creation and validation plugin for rasterio";
    inherit (src.meta) homepage;
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
  };
}
