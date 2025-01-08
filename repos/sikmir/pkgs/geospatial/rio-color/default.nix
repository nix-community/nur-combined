{
  lib,
  fetchFromGitHub,
  python3Packages,
  rio-mucho,
}:

python3Packages.buildPythonPackage rec {
  pname = "rio-color";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "mapbox";
    repo = "rio-color";
    tag = version;
    hash = "sha256-iJ+whIk3ANop8i712dLE0mJyDMHGnE0tic23H6f67Xg=";
  };

  nativeBuildInputs = with python3Packages; [ cython ];

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
