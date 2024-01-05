{ lib, stdenv, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonPackage rec {
  pname = "contextily";
  version = "1.5.0";
  pyproject = true;
  disabled = python3Packages.pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "geopandas";
    repo = "contextily";
    rev = "v${version}";
    hash = "sha256-JSEjxAD7e2LZktKBL5c+64HosY1VlOqn6+vbCX6MzVs=";
  };

  nativeBuildInputs = with python3Packages; [ setuptools-scm ];

  SETUPTOOLS_SCM_PRETEND_VERSION = version;

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

  checkInputs = with python3Packages; [ pytestCheckHook ];

  doCheck = false;

  meta = with lib; {
    description = "Context geo-tiles in Python";
    homepage = "https://github.com/geopandas/contextily";
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
  };
}
