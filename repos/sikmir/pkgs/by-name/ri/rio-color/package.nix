{
  lib,
  fetchFromGitHub,
  python3Packages,
  rio-mucho,
}:

python3Packages.buildPythonPackage rec {
  pname = "rio-color";
  version = "2.0.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mapbox";
    repo = "rio-color";
    tag = version;
    hash = "sha256-iJ+whIk3ANop8i712dLE0mJyDMHGnE0tic23H6f67Xg=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "numpy==2.0.2" "numpy" \
      --replace-fail "cython==3.0.11" "cython"
  '';

  build-system = with python3Packages; [
    setuptools
    cython
    numpy
  ];

  dependencies = with python3Packages; [
    click
    rasterio
    rio-mucho
  ];

  doCheck = false;

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  pythonImportsCheck = [ "rio_color" ];

  meta = {
    description = "Color correction plugin for rasterio";
    homepage = "https://github.com/mapbox/rio-color";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
