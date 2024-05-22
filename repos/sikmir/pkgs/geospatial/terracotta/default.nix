{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "terracotta";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "DHI-GRAS";
    repo = "terracotta";
    rev = "refs/tags/v${version}";
    hash = "sha256-HWNV5MwbylpcJ/u0iFe8gJJLdnvrnK4S8UMSCpuBlqs=";
  };

  postPatch = ''
    substituteInPlace setup.py --replace-fail "\"setuptools_scm_git_archive\"," ""
  '';

  nativeBuildInputs = with python3Packages; [
    setuptools-scm
    #setuptools-scm-git-archive
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
    sqlalchemy
    rasterio
    toml
    tqdm
  ];

  doCheck = false;

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = with lib; {
    description = "A light-weight, versatile XYZ tile server";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
