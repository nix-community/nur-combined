{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "pymbtiles";
  version = "2021-02-16";

  src = fetchFromGitHub {
    owner = "consbio";
    repo = "pymbtiles";
    rev = "5094f77de6fb920092952df68aa64f91bf2aa097";
    hash = "sha256-aBp3ocXkHsb9vimvhgOn2wgfTM0GMuA4mTcqeFsLQzc=";
  };

  checkInputs = with python3Packages; [ pytestCheckHook ];

  meta = with lib; {
    description = "Python utilities for Mapbox mbtiles files";
    inherit (src.meta) homepage;
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
  };
}
