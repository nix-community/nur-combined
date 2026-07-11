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
  version = "0.2.1-unstable-2026-07-11";

  src = fetchFromGitHub {
    owner = "quantum5";
    repo = pname;
    rev = "9b2bf407fabf0ec6862d93e23e0fd8473874fcf9";
    hash = "sha256-oMhEUJGJdwOjLLhUiFKH5XRyKhgXIkY8Veovfghs/UE=";
  };

  pyproject = true;
  build-system = [ python313Packages.setuptools ];

  propagatedBuildInputs = with python313Packages; [
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
