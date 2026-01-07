{
  lib,
  python313Packages,
  fetchFromGitHub,
}:

let
  inherit (python313Packages) buildPythonPackage;
in

buildPythonPackage rec {
  pname = "win2xcur";
  version = "0.1.2-unstable-2026-01-07";

  src = fetchFromGitHub {
    owner = "quantum5";
    repo = pname;
    rev = "25f96bc5f1925d3d7ecb7c62a048223763344a43";
    hash = "sha256-m/1kGb1DzsTVNhbzrxJj3Bpi61dS4B66dH7nRWNIUhE=";
  };

  pyproject = true;
  build-system = [ python313Packages.setuptools ];

  propagatedBuildInputs = with python313Packages; [
    numpy
    wand
  ];

  doCheck = false;

  meta = with lib; {
    description = "A tool to convert Windows .cur and .ani cursors to Xcursor format.";
    homepage = "https://github.com/quantum5/win2xcur";
    license = licenses.unfree; # No license upstream
    maintainers = with maintainers; [ weathercold ];
    platforms = platforms.all;
  };
}
