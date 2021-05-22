{ lib, fetchFromGitHub, python3Packages, gdal }:

python3Packages.buildPythonPackage rec {
  pname = "rasterio";
  version = "1.2.3";
  disabled = python3Packages.pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "mapbox";
    repo = pname;
    rev = version;
    hash = "sha256-IR3WHDYUEJbLdscVRmbTUbH/5WswVTJlwlnGLNrI5A8=";
  };

  nativeBuildInputs = [ gdal python3Packages.cython ];

  propagatedBuildInputs = with python3Packages; [ affine attrs boto3 click-plugins cligj matplotlib numpy snuggs setuptools ];

  checkInputs = with python3Packages; [ pytestCheckHook hypothesis shapely ];

  installCheckPhase = "$out/bin/rio --version";

  meta = with lib; {
    description = "Python package to read and write geospatial raster data";
    homepage = "https://rasterio.readthedocs.io/";
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
  };
}
