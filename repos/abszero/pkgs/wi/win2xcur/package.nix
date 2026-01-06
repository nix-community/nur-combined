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
    rev = "fab83c2c39bc5dcf04ce0669cabcabd099a067eb";
    hash = "sha256-gaR+Uzmn7sH/9+VX/CRVEVXhlzAtsE6izfmMzQ1MLME=";
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
