{ lib, fetchFromGitHub, python3Packages, apispec-webframeworks }:

python3Packages.buildPythonApplication rec {
  pname = "terracotta";
  version = "0.7.5";

  src = fetchFromGitHub {
    owner = "DHI-GRAS";
    repo = pname;
    rev = "refs/tags/v${version}";
    hash = "sha256-Q1rn7Rm1W0itXyuph/aApP+mCSy1VybIoBdEJm6GO68=";
  };

  nativeBuildInputs = with python3Packages; [
    setuptools-scm
    setuptools-scm-git-archive
  ];

  SETUPTOOLS_SCM_PRETEND_VERSION = version;

  propagatedBuildInputs = with python3Packages; [
    apispec
    apispec-webframeworks
    cachetools
    click
    click-spinner
    flask
    flask-cors
    marshmallow
    mercantile
    numpy
    pillow
    pyyaml
    shapely
    rasterio
    toml
    tqdm
  ];

  doCheck = false;

  checkInputs = with python3Packages; [ pytestCheckHook ];

  meta = with lib; {
    description = "A light-weight, versatile XYZ tile server";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
