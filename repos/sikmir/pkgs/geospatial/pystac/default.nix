{ lib, stdenv, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "pystac";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "stac-utils";
    repo = "pystac";
    rev = "v${version}";
    hash = "sha256-khhiCUNiaxC744J+fZiJOXruNILOXvAwe3UNygr2M8U=";
  };

  propagatedBuildInputs = with python3Packages; [
    dateutil
  ];

  doCheck = false;

  checkInputs = with python3Packages; [ jsonschema pytestCheckHook ];

  pythonImportsCheck = [ "pystac" ];

  meta = with lib; {
    description = "Python library for working with any SpatioTemporal Asset Catalog (STAC)";
    inherit (src.meta) homepage;
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
  };
}
