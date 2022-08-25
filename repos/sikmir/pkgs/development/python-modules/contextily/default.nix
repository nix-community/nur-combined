{ lib, stdenv, python3Packages, fetchFromGitHub, xyzservices }:

python3Packages.buildPythonPackage rec {
  pname = "contextily";
  version = "1.2.0";
  disabled = python3Packages.pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "geopandas";
    repo = "contextily";
    rev = "v${version}";
    hash = "sha256-ByLPd75MZCsa8l24lkIZVNX4RrT8LN3D0O4tLOb6hTI=";
  };

  propagatedBuildInputs = with python3Packages; [
    geopy
    matplotlib
    mercantile
    pillow
    rasterio
    requests
    joblib
    xyzservices
  ];

  doCheck = false;

  meta = with lib; {
    description = "Context geo-tiles in Python";
    homepage = "https://github.com/geopandas/contextily";
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
  };
}
