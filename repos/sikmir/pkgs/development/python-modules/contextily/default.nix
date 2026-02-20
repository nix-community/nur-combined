{
  lib,
  stdenv,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "contextily";
  version = "1.6.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "geopandas";
    repo = "contextily";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Pkw21EOjRiIhdZvCY6JJ2T2yjShF9Io4NAQZIIjeKpU=";
  };

  build-system = with python3Packages; [ setuptools-scm ];

  SETUPTOOLS_SCM_PRETEND_VERSION = finalAttrs.version;

  dependencies = with python3Packages; [
    geopy
    matplotlib
    mercantile
    pillow
    rasterio
    requests
    joblib
    xyzservices
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  doCheck = false;

  meta = {
    description = "Context geo-tiles in Python";
    homepage = "https://github.com/geopandas/contextily";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
    broken = stdenv.isDarwin; # postgresql-test-hook
  };
})
