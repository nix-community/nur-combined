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
    rev = "ea8366bc9d217e2f6112dac4dc50eac6d4386e90";
    hash = "sha256-ctT3zxvxrNbAwNvPvhLjV5RkhSG15LAYXm3+zZiEYUE=";
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
