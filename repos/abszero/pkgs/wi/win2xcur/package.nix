{ lib, python39Packages }:

let
  inherit (python39Packages) buildPythonPackage fetchPypi;
in

buildPythonPackage rec {
  pname = "win2xcur";
  version = "0.1.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-B8srOXQBUxK6dZ6GhDA5fYvxUBxHVcrSO/z+UWyF+qI=";
  };

  propagatedBuildInputs = with python39Packages; [
    numpy
    wand
  ];

  doCheck = false;

  meta = with lib; {
    description = "A tool to convert Windows .cur and .ani cursors to Xcursor format.";
    homepage = "https://github.com/quantum5/win2xcur";
    license = licenses.unfree; # No license upstream
    platforms = platforms.all;
  };
}
