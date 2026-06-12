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
  version = "0.2.1-unstable-2026-06-12";

  src = fetchFromGitHub {
    owner = "quantum5";
    repo = pname;
    rev = "a8486eb800274e67a5ce513054ffffb8e372074b";
    hash = "sha256-OkeGEpXP2vNyRtgHOn0/JTE9nG3Dgl1fzcpN70eEpEw=";
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
