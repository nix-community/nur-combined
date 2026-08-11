{
  lib,
  python314Packages,
  fetchFromGitHub,
}:

let
  inherit (python314Packages) buildPythonPackage;
in

buildPythonPackage rec {
  pname = "win2xcur";
  version = "0.2.1-unstable-2026-08-11";

  src = fetchFromGitHub {
    owner = "quantum5";
    repo = pname;
    rev = "a4c5b475e977b69e45d3908f76f32bfc503f1214";
    hash = "sha256-Yj/5LqgIv3i2uKWVJ0IrEnKmGcdpILdNyDgO9EzoRmQ=";
  };

  pyproject = true;
  build-system = [ python314Packages.setuptools ];

  propagatedBuildInputs = with python314Packages; [
    numpy
    wand
  ];

  doCheck = false;

  meta = with lib; {
    description = "Tool to convert Windows .cur and .ani cursors to Xcursor format";
    homepage = "https://github.com/quantum5/win2xcur";
    license = licenses.unfree; # No license upstream
    maintainers = with maintainers; [ weathercold ];
    platforms = platforms.all;
  };
}
