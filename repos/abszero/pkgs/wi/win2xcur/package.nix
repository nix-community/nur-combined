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
  version = "0.2.0-unstable-2026-01-08";

  src = fetchFromGitHub {
    owner = "quantum5";
    repo = pname;
    rev = "a95dea3867f2b60af35c703f5f4c886c0828b7f9";
    hash = "sha256-uG9yrH1BvdGyFosGBXLNB7lr0w7r89MWhW4gCVS+s1w=";
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
