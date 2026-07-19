{
  lib,
  stdenv,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "earthpy";
  version = "0.10.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "earthlab";
    repo = "earthpy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2ThKdynYCnCR0ViE0yeK8BJjtexVdYGU4oOqBAUb9Yw=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    geopandas
    keyring
    matplotlib
    numpy
    platformdirs
    rasterio
    requests
    scikit-image
  ];

  doCheck = false;

  meta = {
    description = "A package built to support working with spatial data using open source python";
    homepage = "https://github.com/earthlab/earthpy";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
    broken = stdenv.isDarwin; # postgresql-test-hook
  };
})
