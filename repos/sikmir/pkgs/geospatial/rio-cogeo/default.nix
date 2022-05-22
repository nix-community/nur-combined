{ lib, stdenv, fetchFromGitHub, python3Packages, morecantile }:

python3Packages.buildPythonPackage rec {
  pname = "rio-cogeo";
  version = "3.2.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "cogeotiff";
    repo = pname;
    rev = version;
    hash = "sha256-Xv3HgQP0PQZeu59LYCt3BuAUPPzKvdHndiemoSIcUec=";
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
