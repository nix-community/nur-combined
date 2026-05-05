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
  version = "0-unstable-2026-05-05";

  src = fetchFromGitHub {
    owner = "quantum5";
    repo = pname;
    rev = "c8a390b79456a45104fe42133b9d7eb4ce7c8638";
    hash = "sha256-b8gXb2/jB8/YpHSkSc/Sz3M8LI2xHxQjjkQpy53juAs=";
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
