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
  version = "0.2.0-unstable-2026-01-09";

  src = fetchFromGitHub {
    owner = "quantum5";
    repo = pname;
    rev = "f226fd54d7e9fe95ccded8fdaad175946a5acede";
    hash = "sha256-d0TRLM1Zesi13gELEUYSCTUHGasT+4M/E0kh90NjFWo=";
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
