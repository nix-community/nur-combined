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
  version = "0.1.2-unstable-2026-01-06";

  src = fetchFromGitHub {
    owner = "quantum5";
    repo = pname;
    rev = "49fc2d33792fe292bb657c92ac253a24c140b321";
    hash = "sha256-TlxiA9kwYDTG+cRUi4LkX4x1sLISAj9OOhCW9fr+6YU=";
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
