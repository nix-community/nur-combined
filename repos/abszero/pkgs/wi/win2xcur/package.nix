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
  version = "0.2.0-unstable-2026-02-16";

  src = fetchFromGitHub {
    owner = "quantum5";
    repo = pname;
    rev = "ac8ec3ebb9d908de49b4d345e9aa5e2ae20ed834";
    hash = "sha256-adfN4M911LwEqHomvAB+pqL91yoIAcq/TxI5ZIEkskk=";
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
