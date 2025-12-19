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
  version = "0.1.2-unstable-2024-01-13";

  src = fetchFromGitHub {
    owner = "quantum5";
    repo = pname;
    rev = "8e71037f5f90f3cea82a74fe516ee637dea113fa";
    hash = "sha256-4Evd3Aa2gpS2J+vkflV/aQypX419l8gI3Pa39wF9D0U=";
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
