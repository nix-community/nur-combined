{ lib, stdenv, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonPackage rec {
  pname = "contextily";
  version = "1.3.0";
  disabled = python3Packages.pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "geopandas";
    repo = "contextily";
    rev = "v${version}";
    hash = "sha256-s8F70I9xrNvYqS8t2kWX7cgjfGqGYLfiAZAYvaKVS6s=";
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
    broken = stdenv.isDarwin; # xyzservices
  };
}
