{ fetchFromGitHub
, pythonPackages
, taskwarrior }:

with pythonPackages;

buildPythonPackage rec {
  pname = "vit";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "scottkosty";
    repo = pname;
    rev = "v${version}";
    sha256 = "1jdxbyzsw2zbrkb4dh2nk15klmbnss8qa61kbxymvli80dd4ga3x";
  };

  propagatedBuildInputs = [
    pytz
    tasklib
    tzlocal
    urwid
  ];

  makeWrapperArgs = [ "--prefix" "PATH" ":" "${taskwarrior}/bin" ];

  preCheck = ''
    export TERM=linux
  '';

  meta.broken = python.isPy2;
}
