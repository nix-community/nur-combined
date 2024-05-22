{
  lib,
  stdenv,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage rec {
  pname = "earthpy";
  version = "0.9.4";

  src = fetchFromGitHub {
    owner = "earthlab";
    repo = "earthpy";
    rev = "v${version}";
    hash = "sha256-MCyeFXtjOqnVarSUk7Z/+Y5oNhYLlxznjWHQOCgUOIc=";
  };

  propagatedBuildInputs = with python3Packages; [
    geopandas
    matplotlib
    numpy
    rasterio
    scikitimage
    requests
  ];

  doCheck = false;

  meta = with lib; {
    description = "A package built to support working with spatial data using open source python";
    inherit (src.meta) homepage;
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
  };
}
