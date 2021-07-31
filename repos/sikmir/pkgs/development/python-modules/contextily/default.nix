{ lib, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonPackage rec {
  pname = "contextily";
  version = "1.1.0";
  disabled = python3Packages.pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "geopandas";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-ftsZRLeOWmqXbgw8E2FIoRSkjz4tuhQgHVbhNULaauQ=";
  };

  propagatedBuildInputs = with python3Packages; [
    geopy
    matplotlib
    mercantile
    pillow
    rasterio
    requests
    joblib
  ];

  doCheck = false;

  meta = with lib; {
    description = "Context geo-tiles in Python";
    homepage = "https://github.com/geopandas/contextily";
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
  };
}
