{
  lib,
  fetchFromGitHub,
  python3Packages,
  rio-mucho,
}:

python3Packages.buildPythonPackage rec {
  pname = "rio-color";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "mapbox";
    repo = "rio-color";
    rev = version;
    hash = "sha256-bkXDw8MW0Q+xhYbfN7vexNUzTIjT9c67e6adavQSP1A=";
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
