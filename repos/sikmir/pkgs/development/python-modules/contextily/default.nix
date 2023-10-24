{ lib, stdenv, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonPackage rec {
  pname = "contextily";
  version = "1.4.0";
  pyproject = true;
  disabled = python3Packages.pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "geopandas";
    repo = "contextily";
    rev = "v${version}";
    hash = "sha256-42ze/ByGLq2/+WghXpkBCaI9lMNAUFDfoUyU5EEBop4=";
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

  meta = with lib; {
    description = "Context geo-tiles in Python";
    homepage = "https://github.com/geopandas/contextily";
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
  };
}
