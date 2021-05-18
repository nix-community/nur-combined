{ lib, fetchFromGitHub, python3Packages, gdal }:

python3Packages.buildPythonPackage rec {
  pname = "rasterio";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "mapbox";
    repo = pname;
    rev = version;
    hash = "sha256-IR3WHDYUEJbLdscVRmbTUbH/5WswVTJlwlnGLNrI5A8=";
  };

  nativeBuildInputs = [ gdal python3Packages.cython ];

  propagatedBuildInputs = with python3Packages; [ affine attrs boto3 click-plugins cligj matplotlib numpy snuggs setuptools ];

  checkInputs = with python3Packages; [ pytestCheckHook hypothesis ];

  installCheckPhase = "$out/bin/rio --version";

  meta = with lib; {
    description = "Rasterio reads and writes geospatial raster datasets";
    homepage = "https://rasterio.readthedocs.io/";
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
  };
}
