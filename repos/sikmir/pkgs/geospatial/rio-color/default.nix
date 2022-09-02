{ lib, stdenv, fetchFromGitHub, python3Packages, rio-mucho }:

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

  propagatedBuildInputs = with python3Packages; [
    click
    rasterio
    rio-mucho
  ];

  doCheck = false;

  checkInputs = with python3Packages; [ pytestCheckHook ];

  pythonImportsCheck = [ "rio_color" ];

  meta = with lib; {
    description = "Color correction plugin for rasterio";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
