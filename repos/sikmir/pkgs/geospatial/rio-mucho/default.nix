{ lib, stdenv, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "rio-mucho";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "mapbox";
    repo = "rio-mucho";
    rev = version;
    hash = "sha256-yr79Lb02vxp2CN+638S8CFxbtim+zrkjxhjwEkx0XsY=";
  };

  propagatedBuildInputs = with python3Packages; [
    click
    numpy
    rasterio
  ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  meta = with lib; {
    description = "Parallel processing wrapper for rasterio";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
