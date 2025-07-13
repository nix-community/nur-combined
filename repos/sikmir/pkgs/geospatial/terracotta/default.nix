{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "terracotta";
  version = "0.9.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "DHI-GRAS";
    repo = "terracotta";
    tag = "v${version}";
    hash = "sha256-PWXm3TDtHyHfpsX1revK6G0yUP0fBr2QqJC1vCr51gI=";
  };

  postPatch = ''
    substituteInPlace setup.py --replace-fail "\"setuptools_scm_git_archive\"," ""
  '';

  build-system = with python3Packages; [
    setuptools-scm
    #setuptools-scm-git-archive
  ];

  SETUPTOOLS_SCM_PRETEND_VERSION = version;

  dependencies = with python3Packages; [
    apispec
    apispec-webframeworks
    cachetools
    click
    click-spinner
    color-operations
    flask
    flask-cors
    marshmallow
    mercantile
    numpy
    pillow
    pyyaml
    shapely
    sqlalchemy
    rasterio
    toml
    tqdm
  ];

  doCheck = false;

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = {
    description = "A light-weight, versatile XYZ tile server";
    homepage = "https://github.com/DHI-GRAS/terracotta";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
