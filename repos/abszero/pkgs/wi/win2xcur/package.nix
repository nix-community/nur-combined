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
  version = "0.2.0-unstable-2026-01-13";

  src = fetchFromGitHub {
    owner = "quantum5";
    repo = pname;
    rev = "feadbe284f502387b6d00fdd688138f6b0faa202";
    hash = "sha256-dO9JXb69JNkx0I8YOnjx+2bYnB7pptkJOKNyWHriCS4=";
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
