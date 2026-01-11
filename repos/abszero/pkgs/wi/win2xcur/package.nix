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
  version = "0.2.0-unstable-2026-01-10";

  src = fetchFromGitHub {
    owner = "quantum5";
    repo = pname;
    rev = "7ba39581dd28d16f9b8f83f012bcb6b759c381a3";
    hash = "sha256-6UpRkFSFAIrbJMYQ5UGseTLWQRwaumBeBEEXqquPIu0=";
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
